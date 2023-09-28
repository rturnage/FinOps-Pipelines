#!/usr/bin/python
"""Validate imported data."""
import argparse
import errno
import glob
import logging
import os
import pathlib
import subprocess
from datetime import datetime

from dotenv import load_dotenv

load_dotenv()

AZCOPY_PATH = os.environ.get("AZCOPY_PATH")
BILLING_LOOKUP_PATH = os.environ.get("LOCAL_BILLING_LOOKUP_PATH")
LOCAL_BILLING_TEST_DATA_PATH = os.environ.get("LOCAL_BILLING_TEST_DATA_PATH")
CONTAINER_NAME = os.environ.get("STORAGE_BACKUP_CONTAINER_NAME")
DATA_DIR = os.environ.get("LOCAL_BILLING_TEST_DATA_PATH")
STORAGE_ACCOUNT_NAME = os.environ.get("STORAGE_ACCOUNT_NAME")
STORAGE_BILLING_DIRECTORY = os.environ.get("STORAGE_BILLING_DIRECTORY")
STORAGE_BILLING_ACTUAL_PATH = os.environ.get("STORAGE_BILLING_ACTUAL_PATH")
STORAGE_BILLING_AMORTIZED_PATH = os.environ.get("STORAGE_BILLING_AMORTIZED_PATH")
STORAGE_SAS_QUERY_ARG = os.environ.get("STORAGE_SAS_QUERY_ARG")
PATH_URL = "https://%s.blob.core.windows.net/%s/%s/%s%s"
PROJ_ROOT_PATH = str(pathlib.Path(__file__).parent.parent.resolve())


def setup_logging():
    """Configure logger."""
    simple_format = logging.Formatter(
        "%(funcName)s(%(lineno)d) %(levelname)s %(message)s"
    )
    with_time_format = logging.Formatter(
        "%(asctime)s %(funcName)s(%(lineno)d) %(levelname)s %(message)s"
    )

    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG)
    console_handler.setFormatter(simple_format)

    file_handler = logging.FileHandler("validate_data.log", encoding="utf-8")
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(with_time_format)

    # create logger
    logger = logging.getLogger()
    logger.setLevel(logging.NOTSET)
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)


def lookup_standard_file_name(cost_type, month):
    """Lookup the file_name used as a standard for the given cost_type and month."""
    standard_file_name = None
    if cost_type == "actual":
        lookup_file = "actual_cost_files"
    if cost_type == "amortized":
        lookup_file = "amortized_cost_files"

    lookup_file_path = os.path.join(PROJ_ROOT_PATH, BILLING_LOOKUP_PATH, lookup_file)
    _LOGGER.debug("Lookup standard file_name in %s", lookup_file_path)
    with open(lookup_file_path, newline="", encoding="utf-8") as file:
        for file_name in file:
            file_name = file_name.strip()
            if month in file_name:
                standard_file_name = file_name

    if not standard_file_name:
        _LOGGER.error(
            "Standard file not found in %s for %s and %s", lookup_file, cost_type, month
        )
        raise ValueError(
            f"Standard file not found in {lookup_file} for {cost_type} and {month}"
        )

    return standard_file_name


def find_local_file_path(cost_type, month, use_sample=False):
    """Find the local versioned file name."""
    _LOGGER.debug("Find local file path %s and %s", cost_type, month)
    standard_file_name = lookup_standard_file_name(cost_type, month)

    search_path = f"{PROJ_ROOT_PATH}/{LOCAL_BILLING_TEST_DATA_PATH}/*/*.csv"
    if use_sample:
        search_path = f"{PROJ_ROOT_PATH}/{LOCAL_BILLING_TEST_DATA_PATH}/samples/*/*.csv"

    _LOGGER.debug(
        "Find local versioned file for %s in %s\n", standard_file_name, search_path
    )
    for local_file_path in glob.glob(search_path):
        if standard_file_name in local_file_path:
            return local_file_path

    _LOGGER.error(
        "No local versioned file found in %s for %s", search_path, standard_file_name
    )
    raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), standard_file_name)


def set_file_version_path(file_name):
    """Create a versioned file name."""
    _LOGGER.debug("Setting file version for %s", file_name)
    _, file_ext_part = os.path.splitext(file_name)

    dte = datetime.utcnow()
    dte = dte.replace(microsecond=0)
    cur_time = dte.isoformat().replace(":", "")
    cur_time = cur_time.replace("-", "")

    versioned_name = f"{file_name}.v{cur_time}{file_ext_part}"

    file_path = os.path.join(PROJ_ROOT_PATH, DATA_DIR, versioned_name)
    return file_path


def copy_blob_as_azcopy(src_url, dest_url):
    """Use azcopy to copy as block blob."""
    _LOGGER.debug("Copying using azcopy")

    # Check if azcopy is installed
    _LOGGER.debug("Verify az copy exists")
    azcopy_path = os.path.join(PROJ_ROOT_PATH, AZCOPY_PATH, "azcopy")
    az_args = [azcopy_path, "--version"]
    azcopy_found = False
    with subprocess.Popen(az_args, stdout=subprocess.PIPE, shell=False) as proc:
        for line in proc.stdout:
            if "azcopy" in line.decode("utf8"):
                azcopy_found = True
            _LOGGER.debug(
                "".join(
                    [
                        s
                        for s in line.decode("utf8").strip().splitlines(True)
                        if s.strip()
                    ]
                )
            )

    if not azcopy_found:
        _LOGGER.error("azcopy not found on the system.")
        raise RuntimeError("azcopy not found on the system.")

    az_args = [
        azcopy_path,
        "copy",
        src_url,
        dest_url,
    ]

    _LOGGER.debug("Calling process: %s", " ".join(az_args))
    with subprocess.Popen(az_args, stdout=subprocess.PIPE, shell=False) as proc:
        for line in proc.stdout:
            _LOGGER.debug(
                "".join(
                    [
                        s
                        for s in line.decode("utf8").strip().splitlines(True)
                        if s.strip()
                    ]
                )
            )


def download_file(cost_type, month):
    """Download the standard billing file for the cost_type and month."""
    _LOGGER.debug("Download file for %s %s", cost_type, month)
    if cost_type == "actual":
        billing_path = "${STORAGE_BILLING_DIRECTORY}/${STORAGE_BILLING_ACTUAL_PATH}"
    if cost_type == "amortized":
        billing_path = "${STORAGE_BILLING_DIRECTORY}/${STORAGE_BILLING_AMORTIZED_PATH}"

    standard_file_name = lookup_standard_file_name(cost_type, month)

    src_path_url = PATH_URL % (
        STORAGE_ACCOUNT_NAME,
        CONTAINER_NAME,
        billing_path,
        standard_file_name,
        STORAGE_SAS_QUERY_ARG,
    )

    local_file_path = set_file_version_path(standard_file_name)

    _LOGGER.debug("Copying file from %s to %s", src_path_url, local_file_path)
    copy_blob_as_azcopy(src_path_url, local_file_path)

    return local_file_path


def summarize(file_path):
    """Summarize the cost of billing file."""
    _LOGGER.debug("Summarize data for %s", file_path)

    col_cost_in_billing_currency = 17

    row_count = 0
    total_cost = 0

    with open(file_path, "r", encoding="utf-8") as input_file:
        # skip header
        next(input_file)

        for row in input_file:
            row_array = row.split(",")

            cost = row_array[col_cost_in_billing_currency]

            row_count = row_count + 1
            total_cost = total_cost + float(cost)

    _LOGGER.debug("Results: total_cost:%s, row_count:%s", total_cost, row_count)
    return (total_cost, row_count)


def main(cost_type, month, no_download=True, use_sample=False):
    """Validate cost in each month."""
    _LOGGER.debug(
        "Validate data for %s, %s, no_download:%s, use_sample:%s",
        cost_type,
        month,
        no_download,
        use_sample,
    )

    if no_download:
        src_file_path = find_local_file_path(cost_type, month, use_sample)
    else:
        src_file_path = download_file(cost_type, month)

    cost, row_count = summarize(src_file_path)

    _LOGGER.info(
        "results: %-10s %-10s %-15s %-10s %s",
        cost_type,
        month,
        cost,
        row_count,
        src_file_path,
    )


if __name__ == "__main__":
    setup_logging()
    _LOGGER = logging.getLogger()
    _LOGGER.info("starting script")

    parser = argparse.ArgumentParser(
        description="Validate billing data.",
        add_help=True,
    )
    parser.add_argument(
        "--cost_type", "-t", help="Billing Cost Type. (actual or amortized)."
    )
    parser.add_argument("--month", "-m", help="Billing Month data to copy (202305).")
    parser.add_argument(
        "--no_download",
        "-n",
        action="store_true",
        help="Don't download the file. Default True",
    )
    parser.add_argument(
        "--use_sample", "-s", action="store_true", help="Use Sample data. Default False"
    )

    args = parser.parse_args()

    if args.cost_type not in ("actual", "amortized"):
        _LOGGER.error("Cost type must be actual or amortized.")
        raise ValueError("Cost type must be actual or amortized.")

    main(args.cost_type, args.month, args.no_download, args.use_sample)

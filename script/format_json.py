#!/usr/bin/python
"""Format json doc. Sort keys by alpha."""
import argparse
import json
import os
import re
from operator import itemgetter


def sort_json_file(file):
    """Sort json file. This looses case information."""
    new_file = file + ".sort"

    with open(file, encoding="utf-8") as json_file:
        data = json.load(json_file)

    # Sort parameters
    if "parameters" in data:
        data["parameters"] = dict((k.lower(), v) for k, v in data["parameters"].items())

    # Sort resources by type then name
    if "resources" in data:
        data["resources"].sort(key=itemgetter("type"))
        data["resources"].sort(key=itemgetter("name"))

    with open(new_file, "w", encoding="utf-8") as out_file:
        json.dump(data, out_file, sort_keys=True, ensure_ascii=False, indent=4)
        out_file.write("\n")

    os.rename(file, file + ".sort.bak")
    os.rename(new_file, file)


def get_parameter_names_from_json(file):
    """Get original parameter names."""
    parameter_pattern = re.compile(r"parameters\('([a-zA-Z_]+)'\)")
    parameter_names = []

    with open(file, encoding="utf-8") as json_file:
        for line in json_file:
            for match in re.finditer(parameter_pattern, line):
                parameter_names.append(match.groups()[0])

    return sorted(set(parameter_names), key=str.casefold)


def save_parameter_names(file, parameter_names):
    """Save parameters for lookup."""
    new_file = file + ".found"

    if parameter_names and len(parameter_names) > 0:
        with (open(new_file, "w", encoding="utf-8") as out_file,):
            out_file.write("\n".join(sorted(parameter_names, key=str.casefold)))
            out_file.write("\n")

        return new_file

    return None


def load_parameter_names(file):
    """Load parameters from lookup."""
    parameter_names = []

    with (open(file, encoding="utf-8") as in_file,):
        for line in in_file:
            if len(line.strip()) > 0:
                parameter_names.append(line.strip())

    return sorted(set(parameter_names), key=str.casefold)


def replace_parameter_names(file, parameter_names):
    """Replace lowecased parameter name with original."""
    new_file = file + ".case"

    if parameter_names and len(parameter_names) > 0:
        with (
            open(file, encoding="utf-8") as in_file,
            open(new_file, "w", encoding="utf-8") as out_file,
        ):
            for line in in_file:
                for param_name in parameter_names:
                    line = line.replace(param_name.lower(), param_name)
                out_file.write(line)

        os.rename(file, file + ".case.bak")
        os.rename(new_file, file)


def main(file, parameters_file=None):
    """Format json file to sort keys."""
    parameter_names = []

    parameter_names = get_parameter_names_from_json(file)
    lookup_file_name = save_parameter_names(file, parameter_names)

    # Sorting looses all case information on parameter names.
    sort_json_file(file)

    # Append paramter_file values to original_names
    if parameters_file:
        loaded_parameter_names = load_parameter_names(parameters_file)
        parameter_names = sorted(
            set(parameter_names) | set(loaded_parameter_names), key=str.casefold
        )

    replace_parameter_names(file, parameter_names)

    # Return lookup file_name
    if lookup_file_name:
        print(lookup_file_name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Format Json file.",
        add_help=True,
    )
    parser.add_argument("--file", "-f", help="Json file to format.")
    parser.add_argument("--parameters", "-p", help="Parameters to replace.")
    args = parser.parse_args()

    if not args.file:
        raise ValueError("File is required.")

    main(args.file, args.parameters)

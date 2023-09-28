"""Test Format json."""
import os

from script import format_json


def test_version():
    """Test Version."""

    filename = "sample.json"
    path = os.path.join(os.path.dirname(__file__), "fixtures", filename)
    results = format_json.get_parameter_names_from_json(path)
    assert results[0] == "factoryName"

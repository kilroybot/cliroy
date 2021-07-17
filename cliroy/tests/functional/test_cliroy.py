"""

Notice we don't follow the same test structure as in unit tests.
That's because functional tests should test the code from "outside".
So we don't need to follow any hierarchy.

"""

import pytest
from cliroy.__main__ import cli
from typer.testing import CliRunner


class TestCliroy:

    # pytest fixture, passed to all methods by argument
    @pytest.fixture(autouse=True, scope="class")
    def runner(self):
        return CliRunner()

    def test_cliroy_returns_zero(self, runner):
        result = runner.invoke(cli)
        assert not result.exception
        assert result.exit_code == 0

    def test_cliroy_prints_something(self, runner):
        result = runner.invoke(cli)
        assert result.output

    def test_cliroy_prints_help(self, runner):
        result = runner.invoke(cli, ['--help'])
        assert "Usage" in result.output

    def test_cliroy_works_with_arg(self, runner):
        result = runner.invoke(cli, ['--x', 2])
        assert not result.exception
        assert result.exit_code == 0

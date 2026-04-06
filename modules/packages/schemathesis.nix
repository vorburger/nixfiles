{
  perSystem =
    { pkgs, ... }:
    let
      python = pkgs.python3.pkgs;

      harfile = python.buildPythonPackage rec {
        pname = "harfile";
        version = "0.4.0";
        pyproject = true;
        src = python.fetchPypi {
          inherit pname version;
          hash = "sha256-NOLZ7zQQHXaVZr/6s8Qg4Ud3YXQwi+0aA27Y22AMq94=";
        };
        build-system = [ python.hatchling ];
      };

      hypothesis-graphql = python.buildPythonPackage rec {
        pname = "hypothesis-graphql";
        version = "0.12.0";
        pyproject = true;
        src = python.fetchPypi {
          pname = "hypothesis_graphql";
          inherit version;
          hash = "sha256-FfX2m24LmtiJ9Z00DgkdfUgUcTc+tqioWR0SaqVudwA=";
        };
        build-system = [ python.hatchling ];
        dependencies = [
          python.graphql-core
          python.hypothesis
        ];
      };

      hypothesis-jsonschema = python.buildPythonPackage rec {
        pname = "hypothesis-jsonschema";
        version = "0.23.1";
        pyproject = true;
        src = python.fetchPypi {
          inherit pname version;
          hash = "sha256-9KwDICQ0KkFJoQJTmE9aVza4Kz/ir7CIjzg0oxFT8hU=";
        };
        build-system = [ python.setuptools ];
        dependencies = [
          python.hypothesis
          python.jsonschema
        ];
      };

      jsonschema-rs = python.buildPythonPackage rec {
        pname = "jsonschema-rs";
        version = "0.45.1";
        pyproject = true;
        src = python.fetchPypi {
          pname = "jsonschema_rs";
          inherit version;
          hash = "sha256-lMcl38KH/Q0+PAPV2VVhGd8ic4W6kgmAV4GOXNyDbNM=";
        };
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit pname version src;
          hash = "sha256-BKSEhGIEP4f8Snb0ZkWUwo1WQO4cKhySM9D0+jyTUrE=";
        };
        build-system = [
          pkgs.cargo
          pkgs.rustPlatform.cargoSetupHook
          pkgs.rustPlatform.maturinBuildHook
          pkgs.rustc
        ];
      };

      starlette-testclient = python.buildPythonPackage rec {
        pname = "starlette-testclient";
        version = "0.4.1";
        pyproject = true;
        src = python.fetchPypi {
          pname = "starlette_testclient";
          inherit version;
          hash = "sha256-npk//hL6tFYGEWJXgTmGYSJi/hXBu23J45zGhpOsH8U=";
        };
        build-system = [ python.hatchling ];
        dependencies = [
          python.requests
          python.starlette
        ];
      };

    in
    {
      packages.schemathesis = python.buildPythonApplication rec {
        pname = "schemathesis";
        version = "4.15.0";
        pyproject = true;

        src = pkgs.fetchFromGitHub {
          owner = "schemathesis";
          repo = "schemathesis";
          tag = "v${version}";
          hash = "sha256-Puz7H/csee5ZJNJq6aTrCMeGSMxzQTZjnFmDPh1m+S8=";
        };

        build-system = [
          python.hatchling
        ];

        dependencies = [
          python.click
          harfile
          python.httpx
          python.hypothesis
          hypothesis-graphql
          hypothesis-jsonschema
          python.jsonschema
          jsonschema-rs
          python.junit-xml
          python.pyrate-limiter
          python.pytest
          python.pyyaml
          python.requests
          python.rich
          starlette-testclient
          python.tenacity
          python.tomli
          python.typing-extensions
          python.werkzeug

          # allure integration
          python.allure-python-commons
          python.allure-pytest
          pkgs.allure
        ];

        pythonImportsCheck = [
          "schemathesis"
        ];

        meta = {
          description = "Catch API bugs before your users do";
          homepage = "https://github.com/schemathesis/schemathesis";
          license = pkgs.lib.licenses.mit;
          mainProgram = "schemathesis";
        };
      };
    };
}

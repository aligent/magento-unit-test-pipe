# Aligent Magento Unit Testing Pipe

A bitbucket pipe for running Magento unit tests

It is designed to be run in parallell, so you can leverage bitbucket parallel steps. [Example pipeline](#example-pipeline)

The pipe detects a `composer.lock` file and installs packages. If no `composer.lock` file is found, the pipe will create
a new magento project.

## Environment Variables

| Variable              | Usage                                                                                                                                                                                                          |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `COMPOSER_AUTH`       | JSON stringified composer `auth.json` with the relevant configuration you need.                                                                                                                                |
| `REPOSITORY_URL`      | `https://repo.magento.com/` - If using this, make sure the `COMPOSER_AUTH` variable is set. <br>  `https://mirror.mage-os.org/` - Only supports open source edition. <br> Default: `https://repo.magento.com/` |
| `MAGENTO_VERSION`     | (Optional) Default: `magento/project-community-edition:>=2.4.5 <2.4.6` <br> Commerce: `magento/project-enterprise-edition:>=2.4.5 <2.4.6`                                                                      |
| `GROUP`               | (Optional) Specify test group(s) to run. Example: `--group inventory,indexer_dimension` <br> See phpunit [@group annotation](https://phpunit.readthedocs.io/en/9.5/annotations.html#group)                     |
| `TESTS_PATH`          | (Optional) Specify a test path to run. Example `./app/code/The/Module`                                                                                                                                         |
| `COMPOSER_PACKAGES`   | (Optional) Specify a composer package to install (required for individual module repositories). Example`aligent/magento-unit-testing-pipe`                                                                     |

## Example Pipeline
```yml
image: php:8.1

definitions:
  steps:
    - step: &unit
        name: "Unit Tests"
        caches:
          - docker
        script:
          - pipe: docker://aligent/magento-unit-test-pipe:8.1
            variables:
              TESTS_PATH: ../../../vendor/magento/magento2-base/dev/tests/integration/testsuite/Magento/Framework/MessageQueue/TopologyTest.php
              REPOSITORY_URL: https://mirror.mage-os.org/
              GROUP: --group group_a,group_b

pipelines:
  branches:
    production:
      - step: *unit
```

## Running Locally
The pipe can be run locally in order to allow for unit testing without running within Bitbucket.

`/build` should be used as a volume for the current directory, and should also be used as the working directory.

When running for a stand-alone module (i.e. without a `composer.lock` file), you will need to specify the `COMPOSER_PACKAGES` environment variable)
Example:

```shell
docker run -v $PWD:/build --env REPOSITORY_URL=https://mirror.mage-os.org --env COMPOSER_PACKAGES=aligent/magento-unit-tests-path --workdir=/build aligent/magento-unit-test-pipe:8.1
```

## Contributing

Commits published to the `main` branch will trigger an automated build for the latest tag in DockerHub

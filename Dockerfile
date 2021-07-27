FROM continuumio/miniconda3:4.9.2-alpine

# add bash, because it's not available by default on alpine
# also install poetry
RUN apk add --no-cache bash && \
    conda install poetry && \
    conda clean -afy

# create new environment
# see: https://jcristharif.com/conda-docker-tips.html
# warning: for some reason conda can hang on "Executing transaction" for a couple of minutes
COPY environment.yml /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml && \
    conda clean -afy && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.pyc' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete

# "activate" environment for all commands (note: ENTRYPOINT is separate from SHELL)
SHELL ["conda", "run", "--no-capture-output", "-n", "cliroy", "/bin/bash", "-c"]

# add poetry files
COPY ./cliroy/pyproject.toml ./cliroy/poetry.lock /tmp/cliroy/
WORKDIR /tmp/cliroy

# install dependencies only (notice that no source code is present yet) and delete cache
RUN poetry install --no-root && \
    rm -rf ~/.cache/pypoetry

# add source and necessary files
COPY ./cliroy/src/ /tmp/cliroy/src/
COPY ./cliroy/LICENSE ./cliroy/README.md /tmp/cliroy/

# build wheel by poetry and install by pip (to force non-editable mode)
RUN poetry build -f wheel && \
    python -m pip install --no-cache-dir --find-links=dist cliroy

ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "cliroy", "cliroy"]

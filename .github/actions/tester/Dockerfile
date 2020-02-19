FROM vinay0410/tectonic-image

RUN apt-get update && apt-get install -y --no-install-recommends poppler-utils \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Set home directory to where GitHub Actions are run from
RUN mkdir -p /github/home
RUN /root/.cache/Tectonic/ /github/home/.cache/Tectonic/
RUN rm -rf /root/.cache
ENV HOME /github/home

# Prime the cache to ensure that the packages required by the
# template are downloaded and exists in Tectonic cache
RUN mkdir -p /tmp/cache-primer
COPY cacher.tex /tmp/cache-primer/
RUN tectonic /tmp/cache-primer/cacher.tex
RUN rm -r /tmp/cache-primer

CMD /bin/sh test/run-tests.sh

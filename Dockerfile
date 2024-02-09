# Images to work with
ARG PYTHON_BUILDER_IMAGE
ARG GOOGLE_DISTROLESS_BASE_IMAGE

# Mainstream Python Image containing current Python version
FROM ${PYTHON_BUILDER_IMAGE} as python-base

# Create non root user
RUN useradd -ms /bin/false python

# Use Distroless CC as base
FROM ${GOOGLE_DISTROLESS_BASE_IMAGE}

ARG CHIPSET_ARCH=x86_64-linux-gnu

# Copy Python from Stage 0
COPY --from=python-base /usr/local/lib/ /usr/local/lib/
COPY --from=python-base /usr/local/bin/python /usr/local/bin/python
COPY --from=python-base /etc/ld.so.cache /etc/ld.so.cache

# Common compiled libraries needed for some packages
COPY --from=python-base /lib/${CHIPSET_ARCH}/libz.so.1 /lib/${CHIPSET_ARCH}/
COPY --from=python-base /usr/lib/${CHIPSET_ARCH}/libffi* /usr/lib/${CHIPSET_ARCH}/
COPY --from=python-base /lib/${CHIPSET_ARCH}/libexpat* /lib/${CHIPSET_ARCH}/

# Non root setup
COPY --from=python-base /etc/passwd /etc/passwd
USER python

# Default ENV
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONFAULTHANDLER 1

ENTRYPOINT ["/usr/local/bin/python"]

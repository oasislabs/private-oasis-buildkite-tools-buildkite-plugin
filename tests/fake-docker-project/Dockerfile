FROM alpine:latest

ARG TEST1_ARG
ARG TEST2_ARG
ARG COMMIT_SHA
ARG BUILD_IMAGE_TAG

# Check that all of the build args have been properly set. Fail if any of them
# have not been set
RUN if [[ -z ${TEST1_ARG} ]]; then exit 1; fi
RUN if [[ -z ${TEST2_ARG} ]]; then exit 1; fi
RUN if [[ -z ${COMMIT_SHA} ]]; then exit 1; fi
RUN if [[ -z ${BUILD_IMAGE_TAG} ]]; then exit 1; fi

FROM dev.gitlab.org:5005/gitlab/gitlab-build-images:gitlab-puppeteer

ARG PUPPETEER_VERSION
ARG EXECUTABLE_PATH

ENV PUPPETEER_EXECUTABLE_PATH $EXECUTABLE_PATH

RUN yarn global add puppeteer@$PUPPETEER_VERSION \
  && yarn cache clean \
  && echo "Testing that the chrome executable ($PUPPETEER_EXECUTABLE_PATH) exists" \
  && test -f $PUPPETEER_EXECUTABLE_PATH \
  && test -x $PUPPETEER_EXECUTABLE_PATH

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

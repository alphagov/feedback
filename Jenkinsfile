#!/usr/bin/env groovy

library("govuk")

node {
  govuk.setEnvar("REDIS_URL", "redis://redis")

  govuk.buildProject(
    brakeman: true,
  )
}

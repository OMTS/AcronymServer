# API Usage

## GET Hello
```
curl "https://omts-til-staging.vapor.cloud/hello" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "short": "OMG",
  "long": "Oh my god"
}'
```

## POST Acronyms
```
curl -X "POST" "https://omts-til-staging.vapor.cloud/api/acronyms" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "short": "OMG",
  "long": "Oh my god"
}'
```

## GET Acronyms
```
curl "https://omts-til-staging.vapor.cloud/api/acronyms" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{}'
```
## GET Acronym with ID
```
curl "https://omts-til-staging.vapor.cloud/api/acronyms/7" \
    -H 'Content-Type: application/json; charset=utf-8' \
    -d $'{}'
```

## PUT Acronym with ID
```
curl -X "PUT" "https://omts-til-staging.vapor.cloud/api/acronyms/6" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "short": "BOB",
  "long": "It'"'"'s Robert Actually!"
}'
```

## DELETE Acronym with ID
```
curl -X "DELETE" "https://omts-til-staging.vapor.cloud/api/acronyms/6"
```

## SEARCH Acronym short
```
curl "https://omts-til-staging.vapor.cloud/api/acronyms/search?term=BOB" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{}'
```

## SEARCH Acronym short and long
```
curl "https://omts-til-staging.vapor.cloud/api/acronyms/multiplesearch?term=It%27s%20Robert%20Actually%21" \
      -H 'Content-Type: application/json; charset=utf-8' \
      -d $'{}'
```

## FIRST Acronym
```
curl "https://omts-til-staging.vapor.cloud/api/acronyms/first" \
      -H 'Content-Type: application/json; charset=utf-8' \
      -d $'{}'
```
## Sorted Acronyms
```
curl "https://omts-til-staging.vapor.cloud/api/acronyms/sorted" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{}'
```
## GET Acronyms with sorted param

```
curl "https://omts-til-staging.vapor.cloud/api/acronyms?sorted=true" \
    -H 'Content-Type: application/json; charset=utf-8' \
    -d $'{}'
```

<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/36623515-7293b4ec-18d3-11e8-85ab-4e2f8fb38fbd.png" width="320" alt="API Template">
    <br>
    <br>
    <a href="http://docs.vapor.codes/3.0/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="http://vapor.team">
        <img src="http://vapor.team/badge.svg" alt="Slack Team">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://circleci.com/gh/vapor/api-template">
        <img src="https://circleci.com/gh/vapor/api-template.svg?style=shield" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.1-brightgreen.svg" alt="Swift 4.1">
    </a>
</center>

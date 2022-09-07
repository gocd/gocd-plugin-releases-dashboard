# GoCD Plugins

This project generates the dashboard at https://gocd.github.io/gocd-plugin-releases-dashboard/


# Building

```
bundle install --path .bundle
GITHUB_TOKEN=READ_ONLY_PERSONAL_ACCESS_TOKEN bundle exec rake prepare
bundle exec middleman serve
```

# Publishing

```
bundle install --path .bundle
GITHUB_TOKEN=READ_ONLY_PERSONAL_ACCESS_TOKEN bundle exec rake publish
```

# License

```plain
Copyright 2022 Thoughtworks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```


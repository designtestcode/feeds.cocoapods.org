This application creates and RSS feed containing the last 30 pods added to [CocoaPods/specs](https://github.com/CocoaPods/specs) and during each update it tweets about the new pods.

# App

- Sinatra application
- requires git
- available at http://feeds.cocoapods.org/
- based on [cococapods.org](https://github.com/CocoaPods/CocoaPods.org)

#### Setup

```shell
$ edit .env
$ bundle install
$ foreman start
```

#### Events

- Initialization:
    - the [CocoaPods/specs](https://github.com/CocoaPods/specs) repo is cloned in `tmp/.cocoapods/master`
    - the `public/new-pods.rss` is created
- GitHub callback:
    - the `public/new-pods.rss` is created
    - tweets for the new pods

#### Implementation Notes

- The most challenging part is to get git to show when a file has been added to the master branch of the repo. Some branches are not merged for a long time and those pod should not appear in the feed. However when the branch is eventually merged the pod should have the date of the merge and not the date of the original commit.
    - Apparently is not possible to extract this information from git for all the pods in one shot and needs to be done per each pod.
    - It is important to get the commit date and not author date as this represent the date in which the pod became available in the master repo.
    - If the date is computed correctly every new pod is guaranteed to have a later date than the ones already known
- Finding the date for all pods is a slow operation and too expensive to be done for every feed computation
    - the date should never change and for this reason are cached
    - `pod list new` takes ~18s on iMac 2009 / 163 pods. It takes ~2s on the call because all the information is cached.
    - The feed app should cache the information of published pods, but as the `pod list new` needs the cache as well it simply leverages the existing infrastructure. For this reason it is possible to specify the path of the cache_file in `Pod::Specification::Statistics`
- GitHub stats require a network roundtrip for every pod.
    - As the watcher and the followers change slowly the pod command caches this information for 3 days.
    - The feed app to preserve dyno time in the feed generation simply offers a snapshot at the publication of the pod in the feed.
        - i.e. the `cache_duration` in `Pod::Specification::Statistics` is set to a huge time.

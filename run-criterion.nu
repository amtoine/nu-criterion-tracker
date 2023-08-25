#!/usr/bin/env nu

def main [] {
    for repo in (open projects.nuon) {
        print $"(ansi red)running criterion for (ansi red_bold)($repo.local)(ansi reset)"

        let path = (["repos" $repo.local] | path join)

        git clone $repo.remote $path

        mkdir $repo.local

        cargo criterion --manifest-path ({
            parent: $path
            stem: "Cargo"
            extension: "toml"
        } | path join) --output-format verbose --message-format json | lines | each {|| from json }
        | where reason == "benchmark-complete" | reject reason
        | to nuon --raw
        | save ({
            parent: $repo.local
            stem: (date now | format date "%Y-%m-%dT%H:%M:%S")
            extension: "nuon"
        } | path join)
    }
}

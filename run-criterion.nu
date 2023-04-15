def main [] {
    for repo in (open projects.nuon) {
        print -n $"(ansi erase_line)updating issue tracker of ($repo)\r"

        let path = (["repos" $repo] | path join)

        git clone ({
            scheme: "http"
            host: "github.com"
            path: $repo
        } | url join) $path

        cargo criterion --manifest-path ({
            parent: $path
            stem: "Cargo"
            extension: "toml"
        } | path join) --output-format verbose --message-format json | lines | each { from json }
        | where reason == "benchmark-complete" | reject reason
        | to nuon --raw
        | save ({
            parent: $repo
            stem: (date now | date format "%Y-%m-%dT%H:%M:%S")
            extension: "nuon"
        } | path join)
    }
}

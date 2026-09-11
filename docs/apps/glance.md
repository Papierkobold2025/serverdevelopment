# Glance Integration

- Glance was integrated in the infrastructure in order to have a platform where I can search and read all the news pertinent to my infrastructure and it's security. 

## Decisions

- Glance was chosen as it adapts better to my needs and organizational likings.

- Glance was integrated in the K3s cluster as the service is not critical and fits perfectly the reasoning by which the stack has been built.

## Configuration

pages:
  - name: Home
    columns:
      - size: small
        widgets:
          - type: calendar
            first-day-of-week: monday

          - type: search
            search-engine: duckduckgo

          - type: rss
            limit: 10
            collapse-after: 3
            cache: 12h
            feeds:
              - url: https://selfh.st/rss/
                title: selfh.st
                limit: 4
              - url: https://ciechanow.ski/atom.xml
              - url: https://www.joshwcomeau.com/rss.xml
                title: Josh Comeau
              - url: https://samwho.dev/rss.xml
              - url: https://ishadeed.com/feed.xml
                title: Ahmad Shadeed

      - size: full
        widgets:
          - type: group
            widgets:
              - type: hacker-news
              - type: lobsters

          - type: videos
            channels:
              - UCJxv80y78XTCUqfiplmDyRw # SrTriline
              - UCNnNCBgckxzqIh1Txw5cgSg # SrBaityBait
              - UCKzD3xuVqZIV2OEfhifVkDg # HABLEMOSDELOQUENOEXISTE
              - UCODHrzPMGbNv67e84WDZhQQ # fern-tv
              - UCG-48Ki-b6W_siaUkukJOSw # SimplyCyber
              - UCv6J_jJa8GJqFwQNgNrMuww # ServeTheHomeVideo
              - UCGdQlv3wbQPK6Iv3YAYvTKA # Relatosdelanoche

          - type: group
            widgets:
              - type: reddit
                subreddit: technology
                show-thumbnails: true
              - type: reddit
                subreddit: selfhosted
                show-thumbnails: true
              - type: reddit
                subreddit: cybersecurity
                show-thumbnails: true

          - type: custom-api
            title: CVEs - Automatización y Red
            cache: 1h
            url: https://cve.assurestart.co/api?term=npm,pihole,k3s,kubernetes,github,semaphore,ansible,terraform,homarr,wazuh&cvss_min=7
            template: |
              <ul class="list list-gap-10">
                {{ range .JSON.Array "data" }}
                <li>
                  <strong>[{{ .String "cvss_severity" }}]</strong>
                  <a href="{{ .String "link" }}" target="_blank">{{ .String "cve_id" }}</a>
                  — <em>{{ range .Array "vendors" }}{{ .String "" }} {{ end }}</em>
                  <span {{ .String "created_at" | parseTime "rfc3339" | toRelativeTime }}></span>
                  <p>{{ .String "title" }}</p>
                </li>
                {{ end }}
              </ul>

          - type: custom-api
            title: CVEs - OS y Apps
            cache: 1h
            url: https://cve.assurestart.co/api?term=ubuntu,nextcloud,wings,pterodactyl,wireguard&cvss_min=7
            template: |
              <ul class="list list-gap-10">
                {{ range .JSON.Array "data" }}
                <li>
                  <strong>[{{ .String "cvss_severity" }}]</strong>
                  <a href="{{ .String "link" }}" target="_blank">{{ .String "cve_id" }}</a>
                  — <em>{{ range .Array "vendors" }}{{ .String "" }} {{ end }}</em>
                  <span {{ .String "created_at" | parseTime "rfc3339" | toRelativeTime }}></span>
                  <p>{{ .String "title" }}</p>
                </li>
                {{ end }}
              </ul>

          - type: custom-api
            title: CVEs - Servicios Extra
            cache: 1h
            url: https://cve.assurestart.co/api?term=netdata,traefik,docker,redis,wg-easy,freshrss,tp-link,anthropic&cvss_min=7
            template: |
              <ul class="list list-gap-10">
                {{ range .JSON.Array "data" }}
                <li>
                  <strong>[{{ .String "cvss_severity" }}]</strong>
                  <a href="{{ .String "link" }}" target="_blank">{{ .String "cve_id" }}</a>
                  — <em>{{ range .Array "vendors" }}{{ .String "" }} {{ end }}</em>
                  <span {{ .String "created_at" | parseTime "rfc3339" | toRelativeTime }}></span>
                  <p>{{ .String "title" }}</p>
                </li>
                {{ end }}
              </ul>

          - type: custom-api
            title: CVEs - Apple / Google / Microsoft
            cache: 1h
            url: https://cve.assurestart.co/api?term=iphone,macos,gmail,microsoft,youtube&cvss_min=7
            template: |
              <ul class="list list-gap-10">
                {{ range .JSON.Array "data" }}
                <li>
                  <strong>[{{ .String "cvss_severity" }}]</strong>
                  <a href="{{ .String "link" }}" target="_blank">{{ .String "cve_id" }}</a>
                  — <em>{{ range .Array "vendors" }}{{ .String "" }} {{ end }}</em>
                  <span {{ .String "created_at" | parseTime "rfc3339" | toRelativeTime }}></span>
                  <p>{{ .String "title" }}</p>
                </li>
                {{ end }}
              </ul>

      - size: small
        widgets:
          - type: weather
            location: Zurich, Switzerland
            units: metric
            hour-format: 24h


# Pi-Hole Ansible Role #

Ansible role for setting up [Pi-hole](https://github.com/pi-hole/pi-hole/) a DNS sinkhole

## Usage ##

```ansible
- name: Install Pihole
  include_role:
    name: pihole
  vars:
    webui_password: "{{ terraform_config.webui_password }}"
    dns_servers: "{{ terraform_config.network.dns_servers }}"
    conditional_forwarding: "{{ terraform_config.conditional_forwarding }}"
    conditional_forwarding_ip: "{{ terraform_config.conditional_forwarding_ip }}"
    conditional_forwarding_domain: "{{ terraform_config.conditional_forwarding_domain }}"
    conditional_forwarding_reverse: "{{ terraform_config.conditional_forwarding_reverse }}"
    extra_block_lists:
      - url: https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/facebook/all-but-whatsapp
        enabled: true

      - url: https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/facebook/all
        enabled: false

      - url: https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/google/localized
        enabled: false

      - url: https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/google/all
        enabled: false

      - url: https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/microsoft/all
        enabled: false

      - url: https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/amazon/all
        enabled: false

      - url: https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/apple/all
        enabled: false

      - url: https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/cloudflare/all
        enabled: false

      - url: https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/mozilla/all
        enabled: false

      - url: https://raw.githubusercontent.com/jmdugan/blocklists/master/corporations/pinterest/all
        enabled: false

      - url: https://raw.githubusercontent.com/durablenapkin/scamblocklist/master/hosts.txt
        enabled: true

      - url: https://gitlab.com/ookangzheng/dbl-oisd-nl/raw/master/dbl.txt
        enabled: true

      - url: http://sysctl.org/cameleon/hosts
        enabled: true

      - url: https://mirror1.malwaredomains.com/files/justdomains
        enabled: true

      - url: https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
        enabled: true

      - url: https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
        enabled: true

      - url: https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
        enabled: true
```

## References ##

- [https://docs.pi-hole.net/](https://docs.pi-hole.net/)

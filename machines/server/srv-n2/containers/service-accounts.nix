{
  containerUsers = [
    "caddy"
    "searxng"
    "privatebin"
    "crowdsec"
  ];

  users.groups.weblogs.members = [
    "caddy"
    "crowdsec"
  ];
}

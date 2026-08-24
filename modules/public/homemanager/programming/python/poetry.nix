{packageSets, ...}: {
  programs.poetry = {
    enable = true;
    # use Poetry 1.8.4
    package = packageSets.poetry.poetry;
    settings = {
      keyring.enabled = false;
      virtualenvs.create = true;
      virtualenvs.in-project = true;
    };
  };
}

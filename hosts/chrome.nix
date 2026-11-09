# Google Chrome managed policies, shared by every NixOS host (written to
# /etc/opt/chrome/policies/managed). Chrome's own settings aren't tracked by the
# home-manager chromium module, and policies can't be set from there.
{
  programs.chromium.enable = true; # only writes the policy files; Chrome is installed via home-manager (modules/gui/chrome.nix)
  programs.chromium.extraOpts = {
    # AI features off
    GeminiSettings = 1; # 1 = disabled
    AIModeSettings = 1;
    HistorySearchSettings = 2; # 2 = disabled
    TabOrganizerSettings = 2;
    TabCompareSettings = 2;
    CreateThemesSettings = 2;
    HelpMeWriteSettings = 2;
    GenAILocalFoundationalModelSettings = 1;

    # Default search engine: DuckDuckGo
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderName = "DuckDuckGo";
    DefaultSearchProviderKeyword = "ddg";
    DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
    DefaultSearchProviderSuggestURL = "https://duckduckgo.com/ac/?q={searchTerms}&type=list";
  };
}

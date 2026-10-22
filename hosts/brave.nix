# Brave managed policies, shared by every NixOS host (written to
# /etc/brave/policies/managed). Brave's own settings aren't tracked by the
# home-manager brave module, and policies can't be set from there.
{
  programs.chromium.enable = true; # only writes the policy files; Brave is installed via home-manager
  programs.chromium.extraOpts = {
    # AI features off
    BraveAIChatEnabled = false; # Leo
    GeminiSettings = 1; # 1 = disabled
    AIModeSettings = 1;
    HistorySearchSettings = 2; # 2 = disabled
    TabOrganizerSettings = 2;
    TabCompareSettings = 2;
    CreateThemesSettings = 2;
    HelpMeWriteSettings = 2;
    GenAILocalFoundationalModelSettings = 1;

    # Other Brave extras off
    BraveRewardsDisabled = true;
    BraveWalletDisabled = true;
    BraveNewsDisabled = true;
    BraveTalkDisabled = true;
  };
}

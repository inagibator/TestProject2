inherited K_FrameCDRel: TK_FrameCDRel
  inherited ActList: TActionList
    object AddCDim: TAction
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' ...'
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' ...'
      ImageIndex = 190
      OnExecute = AddCDimExecute
    end
    object DelCDim: TAction
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077
      ImageIndex = 191
      OnExecute = DelCDimExecute
    end
  end
end

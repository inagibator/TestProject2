object K_FrameCSDim1: TK_FrameCSDim1
  Left = 0
  Top = 0
  Width = 301
  Height = 57
  TabOrder = 0
  inline K_FrameRAEditS: TK_FrameRAEdit
    Left = 0
    Top = 0
    Width = 301
    Height = 57
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    inherited SGrid: TStringGrid
      Width = 301
      Height = 57
    end
    inherited BtExtEditor: TButton
      Left = 32
      Top = 4
    end
  end
  object ActionList2: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 272
    object AddAll: TAction
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074#1089#1077
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074#1089#1077
      ImageIndex = 135
      OnExecute = AddAllExecute
    end
    object DelAll: TAction
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1089#1077
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1074#1089#1077
      ImageIndex = 17
      OnExecute = DelAllExecute
    end
  end
end

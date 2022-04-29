inherited K_FormRASearchReplace: TK_FormRASearchReplace
  Left = 235
  Top = 103
  Width = 493
  Height = 161
  Caption = 'K_FormRASearchReplace'
  PixelsPerInch = 96
  TextHeight = 13
  object LbSearch: TLabel [0]
    Left = 0
    Top = 0
    Width = 22
    Height = 13
    Caption = #1063#1090#1086':'
  end
  object LbReplace: TLabel [1]
    Left = 0
    Top = 47
    Width = 68
    Height = 13
    Caption = #1047#1072#1084#1077#1085#1080#1090#1100' '#1085#1072':'
  end
  object LbSearchCaption: TLabel [2]
    Left = 114
    Top = 1
    Width = 31
    Height = 13
    Caption = #1053#1072#1081#1090#1080
    Visible = False
  end
  object LbReplaceCaption: TLabel [3]
    Left = 170
    Top = 1
    Width = 50
    Height = 13
    Caption = #1047#1072#1084#1077#1085#1080#1090#1100
    Visible = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 473
    Top = 115
    TabOrder = 10
  end
  object BtToReplace: TButton
    Left = 402
    Top = 73
    Width = 83
    Height = 21
    Caption = #1047#1072#1084#1077#1085#1080#1090#1100' ...'
    TabOrder = 3
    OnClick = BtToReplaceClick
  end
  object EdiSearch: TEdit
    Left = 0
    Top = 17
    Width = 387
    Height = 21
    TabOrder = 0
  end
  object BtSearch: TButton
    Left = 402
    Top = 17
    Width = 83
    Height = 21
    Caption = #1053#1072#1081#1090#1080' '#1076#1072#1083#1077#1077
    TabOrder = 1
    OnClick = BtSearchClick
  end
  object BtClose: TButton
    Left = 402
    Top = 45
    Width = 83
    Height = 21
    Caption = #1047#1072#1082#1088#1099#1090#1100
    ModalResult = 2
    TabOrder = 2
  end
  object BtReplaceAll: TButton
    Left = 402
    Top = 101
    Width = 83
    Height = 21
    Caption = #1047#1072#1084#1077#1085#1080#1090#1100' '#1074#1089#1077
    TabOrder = 4
    OnClick = BtReplaceAllClick
  end
  object BtReplace: TButton
    Left = 402
    Top = 73
    Width = 83
    Height = 21
    Caption = #1047#1072#1084#1077#1085#1080#1090#1100
    TabOrder = 5
    OnClick = BtReplaceClick
  end
  object EdReplace: TEdit
    Left = 0
    Top = 62
    Width = 387
    Height = 21
    TabOrder = 6
  end
  object ChBCase: TCheckBox
    Left = 2
    Top = 103
    Width = 121
    Height = 17
    Caption = #1059#1095#1080#1090#1099#1074#1072#1090#1100' '#1088#1077#1075#1080#1089#1090#1088
    TabOrder = 7
    OnClick = SetStartModeClick
  end
  object ChBCell: TCheckBox
    Left = 133
    Top = 103
    Width = 109
    Height = 17
    Caption = #1071#1095#1077#1081#1082#1072' '#1094#1077#1083#1080#1082#1086#1084
    TabOrder = 8
    OnClick = SetStartModeClick
  end
  object ChBSearhInSelected: TCheckBox
    Left = 252
    Top = 103
    Width = 138
    Height = 17
    Caption = #1048#1089#1082#1072#1090#1100' '#1074' '#1074#1099#1076#1077#1083#1077#1085#1085#1086#1084
    TabOrder = 9
    OnClick = SetStartModeClick
  end
end

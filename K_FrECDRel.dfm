object K_FrameECDRel: TK_FrameECDRel
  Left = 0
  Top = 0
  Width = 553
  Height = 90
  TabOrder = 0
  DesignSize = (
    553
    90)
  object LbIndsType: TLabel
    Left = 378
    Top = 7
    Width = 25
    Height = 13
    Caption = #1058#1080#1087' :'
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 361
    Height = 30
    Align = alNone
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object TBTranspGrid: TToolButton
      Left = 0
      Top = 2
      Action = FrRACDRel.TranspGrid
    end
    object TBRebuildGrid: TToolButton
      Left = 25
      Top = 2
      Action = FrRACDRel.RebuildGrid
    end
    object ToolButton14: TToolButton
      Left = 50
      Top = 2
      Width = 8
      Caption = 'ToolButton14'
      ImageIndex = 198
      Style = tbsSeparator
    end
    object ToolButton1: TToolButton
      Left = 58
      Top = 2
      Action = AddCDim
    end
    object ToolButton2: TToolButton
      Left = 83
      Top = 2
      Action = FrRACDRel.DelCDim
    end
    object ToolButton3: TToolButton
      Left = 108
      Top = 2
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 192
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 116
      Top = 2
      Action = FrRACDRel.AddRow
    end
    object ToolButton5: TToolButton
      Left = 141
      Top = 2
      Action = FrRACDRel.InsRow
    end
    object ToolButton6: TToolButton
      Left = 166
      Top = 2
      Action = FrRACDRel.DelRow
    end
    object ToolButton7: TToolButton
      Left = 191
      Top = 2
      Width = 8
      Caption = 'ToolButton7'
      ImageIndex = 80
      Style = tbsSeparator
    end
    object ToolButton8: TToolButton
      Left = 199
      Top = 2
      Action = SelectROperand
    end
    object ToolButton9: TToolButton
      Left = 224
      Top = 2
      Action = RCProduction
    end
    object ToolButton10: TToolButton
      Left = 249
      Top = 2
      Action = RUnion
    end
    object ToolButton11: TToolButton
      Left = 274
      Top = 2
      Action = RIntersection
    end
    object ToolButton12: TToolButton
      Left = 299
      Top = 2
      Action = RDifference
    end
    object ToolButton13: TToolButton
      Left = 324
      Top = 2
      Width = 8
      Caption = 'ToolButton13'
      ImageIndex = 196
      Style = tbsSeparator
    end
    object ToolButtonCorUDCSDim: TToolButton
      Left = 332
      Top = 2
      Action = SetCorUDCSDim
    end
  end
  inline FrRACDRel: TK_FrameCDRel
    Left = 0
    Top = 29
    Width = 553
    Height = 62
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    inherited SGrid: TStringGrid
      Width = 553
      Height = 62
    end
  end
  object CmBIndsType: TComboBox
    Left = 408
    Top = 4
    Width = 143
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 2
    OnChange = CmBIndsTypeChange
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 441
    Top = 1
    object SelectROperand: TAction
      Caption = #1042#1099#1073#1088#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077' '#1086#1087#1077#1088#1072#1085#1076' ...'
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077' '#1086#1087#1077#1088#1072#1085#1076' '#1076#1083#1103' '#1086#1087#1077#1088#1072#1094#1080#1081' '#1080#1079#1084#1077#1085#1077#1085#1080#1103' ...'
      ImageIndex = 192
      OnExecute = SelectROperandExecute
    end
    object RUnion: TAction
      Caption = 'RUnion'
      ImageIndex = 193
      OnExecute = RUnionExecute
    end
    object RIntersection: TAction
      Caption = 'RIntersection'
      ImageIndex = 194
      Visible = False
    end
    object RDifference: TAction
      Caption = 'RDifference'
      ImageIndex = 195
      Visible = False
    end
    object RCProduction: TAction
      Caption = 'RCProduction'
      ImageIndex = 196
      OnExecute = RCProductionExecute
    end
    object SetCorUDCSDim: TAction
      Caption = #1055#1088#1080#1074#1103#1079#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077' '#1082' '#1074#1085#1077#1096#1085#1077#1084#1091' '#1087#1086#1076#1080#1079#1084#1077#1088#1077#1085#1080#1102' ...'
      Hint = #1055#1088#1080#1074#1103#1079#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077' '#1082' '#1074#1085#1077#1096#1085#1077#1084#1091' '#1087#1086#1076#1080#1079#1084#1077#1088#1077#1085#1080#1102' ...'
      ImageIndex = 197
      OnExecute = SetCorUDCSDimExecute
    end
    object ClearCorUDCSdim: TAction
      Caption = #1053#1072#1088#1091#1096#1080#1090#1100' '#1089#1074#1103#1079#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1103' '#1089' '#1074#1085#1077#1096#1085#1080#1084' '#1087#1086#1076#1080#1079#1084#1077#1088#1077#1085#1080#1077#1084
      Hint = #1053#1072#1088#1091#1096#1080#1090#1100' '#1089#1074#1103#1079#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1103' '#1089' '#1074#1085#1077#1096#1085#1080#1084' '#1087#1086#1076#1080#1079#1084#1077#1088#1077#1085#1080#1077#1084
      ImageIndex = 198
      OnExecute = ClearCorUDCSdimExecute
    end
    object AddCDim: TAction
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' ...'
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' ...'
      ImageIndex = 190
      OnExecute = AddCDimExecute
    end
  end
end

inherited K_FormViewComp: TK_FormViewComp
  Left = 612
  Top = 524
  Width = 320
  Height = 203
  Caption = 'K_FormViewComp'
  KeyPreview = True
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 300
    Top = 157
    TabOrder = 2
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 312
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    EdgeBorders = [ebTop, ebBottom]
    Flat = True
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Action = FitInWindow
    end
    object ToolButton4: TToolButton
      Left = 25
      Top = 0
      Action = ZoomToOriginalSize
    end
    object ToolButton5: TToolButton
      Left = 50
      Top = 0
      Action = ZoomIn
    end
    object ToolButton6: TToolButton
      Left = 75
      Top = 0
      Action = ZoomOut
    end
    object ToolButton2: TToolButton
      Left = 100
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 53
      Style = tbsSeparator
    end
    object ToolButton3: TToolButton
      Left = 108
      Top = 0
      Hint = #1069#1082#1089#1087#1086#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072
      Action = ExportToClipBoard
      Caption = #1069#1082#1089#1087#1086#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072
    end
    object ToolButton8: TToolButton
      Left = 133
      Top = 0
      Width = 8
      Caption = 'ToolButton8'
      ImageIndex = 92
      Style = tbsSeparator
    end
    object ToolButton7: TToolButton
      Left = 141
      Top = 0
      Hint = #1047#1072#1082#1086#1085#1089#1077#1088#1074#1080#1088#1086#1074#1072#1090#1100' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077' '#1074' '#1086#1082#1085#1077' '
      Action = SkipComponentChange
      Caption = #1047#1072#1082#1086#1085#1089#1077#1088#1074#1080#1088#1086#1074#1072#1090#1100' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077
    end
    object ToolButton9: TToolButton
      Left = 166
      Top = 0
      Width = 8
      Caption = 'ToolButton9'
      ImageIndex = 215
      Style = tbsSeparator
    end
    object ToolButton10: TToolButton
      Left = 174
      Top = 0
      Action = SaveComponentCopy
    end
  end
  inline RFrame: TN_Rast1Frame
    Left = 0
    Top = 29
    Width = 312
    Height = 121
    HelpType = htKeyword
    Align = alClient
    Constraints.MinHeight = 104
    Constraints.MinWidth = 78
    Color = clBtnFace
    ParentColor = False
    TabOrder = 1
    inherited PaintBox: TPaintBox
      Width = 296
      Height = 105
    end
    inherited HScrollBar: TScrollBar
      Top = 105
      Width = 312
    end
    inherited VScrollBar: TScrollBar
      Left = 296
      Height = 105
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 150
    Width = 312
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 280
    object FitInWindow: TAction
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1074' '#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1080#1080' '#1089' '#1086#1082#1085#1086#1084
      Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1074' '#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1080#1080' '#1089' '#1086#1082#1085#1086#1084
      ImageIndex = 212
      OnExecute = FitInWindowExecute
    end
    object ExportToClipBoard: TAction
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072
      Hint = #1069#1082#1089#1087#1086#1088#1090' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072
      ImageIndex = 215
      OnExecute = ExportToClipBoardExecute
    end
    object ZoomToOriginalSize: TAction
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1074' '#1088#1072#1079#1088#1077#1096#1077#1085#1080#1080' '#1087#1088#1080#1085#1090#1077#1088#1072
      Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1074' '#1088#1072#1079#1088#1077#1096#1077#1085#1080#1080' '#1087#1088#1080#1085#1090#1077#1088#1072
      ImageIndex = 213
      OnExecute = ZoomToOriginalSizeExecute
    end
    object ZoomIn: TAction
      Caption = #1059#1074#1077#1083#1080#1095#1080#1090#1100
      Hint = #1059#1074#1077#1083#1080#1095#1080#1090#1100
      ImageIndex = 210
      OnExecute = ZoomInExecute
    end
    object ZoomOut: TAction
      Caption = #1059#1084#1077#1085#1100#1096#1080#1090#1100
      Hint = #1059#1084#1077#1085#1100#1096#1080#1090#1100
      ImageIndex = 211
      OnExecute = ZoomOutExecute
    end
    object SkipComponentChange: TAction
      Caption = #1047#1072#1082#1086#1085#1089#1077#1088#1074#1080#1088#1086#1074#1072#1090#1100' '#1089#1086#1089#1090#1086#1103#1085#1080#1077
      ImageIndex = 214
      OnExecute = SkipComponentChangeExecute
    end
    object SaveComponentCopy: TAction
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1086#1087#1080#1102' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103
      Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1086#1087#1080#1102' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103' '#1076#1083#1103' '#1087#1086#1089#1083#1077#1076#1091#1102#1097#1077#1075#1086' '#1088#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1103
      ImageIndex = 33
      OnExecute = SaveComponentCopyExecute
    end
  end
end

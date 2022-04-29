object N_VTreeFrame: TN_VTreeFrame
  Left = 0
  Top = 0
  Width = 124
  Height = 41
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object TreeView: TTreeView
    Left = 0
    Top = 0
    Width = 124
    Height = 41
    Align = alClient
    Images = N_ButtonsForm.IconsList
    Indent = 21
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnCollapsing = TVItemCollapsing
    OnCustomDrawItem = TVDrawItem
    OnDeletion = TVDeletion
    OnEditing = TVEditing
    OnExpanding = TVItemExpanding
    OnMouseDown = TVMouseDown
    OnMouseMove = TVMouseMove
  end
  object EdName: TEdit
    Left = 40
    Top = 9
    Width = 17
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Visible = False
    OnChange = EdNameChange
    OnExit = EdNameExit
    OnKeyDown = EdNameKeyDown
  end
  object ActionList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 64
    Top = 8
    object RenameInline: TAction
      Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' ...'
      OnExecute = RenameInlineExecute
    end
    object StepUp: TAction
      Caption = #1042#1074#1077#1088#1093
      Hint = #1042#1074#1077#1088#1093' '#1087#1086' '#1076#1077#1088#1077#1074#1091' '#1086#1073#1098#1077#1082#1090#1086#1074
      ImageIndex = 115
      OnExecute = StepUpExecute
    end
    object StepDown: TAction
      Caption = #1042#1085#1080#1079
      Hint = #1058#1077#1082#1091#1097#1080#1081' '#1086#1073#1098#1077#1082#1090' '#1089#1076#1077#1083#1072#1090#1100' '#1082#1086#1088#1085#1077#1074#1099#1084
      ImageIndex = 116
      OnExecute = StepDownExecute
    end
    object RenameForm: TAction
      Caption = 'Rename ...'
      ImageIndex = 44
      OnExecute = RenameFormExecute
    end
    object MoveNodeUP: TAction
      Caption = #1042#1099#1073#1088#1072#1085#1085#1099#1081' '#1091#1079#1077#1083' "'#1074#1074#1077#1088#1093'" '
      Hint = #1042#1099#1073#1088#1072#1085#1085#1099#1081' '#1091#1079#1077#1083' "'#1074#1074#1077#1088#1093'" '
      ImageIndex = 93
      OnExecute = MoveNodeUPExecute
    end
    object MoveNodeDown: TAction
      Caption = #1042#1099#1073#1088#1072#1085#1085#1099#1081' '#1091#1079#1077#1083' "'#1074#1085#1080#1079'" '
      Hint = #1042#1099#1073#1088#1072#1085#1085#1099#1081' '#1091#1079#1077#1083' "'#1074#1085#1080#1079'" '
      ImageIndex = 94
      OnExecute = MoveNodeDownExecute
    end
    object ToggleNodesPMark: TAction
      Caption = #1055#1077#1088#1077#1082#1083#1102#1095#1080#1090#1100' '#1087#1086#1089#1090#1086#1103#1085#1085#1086#1077' '#1074#1099#1076#1077#1083#1077#1085#1080#1077' '#1087#1086#1084#1077#1095#1077#1085#1085#1099#1093'  '#1091#1079#1083#1086#1074
      Hint = #1055#1077#1088#1077#1082#1083#1102#1095#1080#1090#1100' '#1087#1086#1089#1090#1086#1103#1085#1085#1086#1077' '#1074#1099#1076#1077#1083#1077#1085#1080#1077' '#1087#1086#1084#1077#1095#1077#1085#1085#1099#1093'  '#1091#1079#1083#1086#1074
      OnExecute = ToggleNodesPMarkExecute
    end
    object ClearNodesPMark: TAction
      Caption = #1059#1073#1088#1072#1090#1100' '#1087#1086#1089#1090#1086#1103#1085#1085#1086#1077' '#1074#1099#1076#1077#1083#1077#1085#1080#1077' '#1091#1079#1083#1086#1074
      Hint = #1059#1073#1088#1072#1090#1100' '#1087#1086#1089#1090#1086#1103#1085#1085#1086#1077' '#1074#1099#1076#1077#1083#1077#1085#1080#1077' '#1091#1079#1083#1086#1074
      OnExecute = ClearNodesPMarkExecute
    end
  end
end

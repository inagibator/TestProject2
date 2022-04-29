inherited K_FormUDVector: TK_FormUDVector
  Left = 377
  Top = 355
  Width = 270
  Height = 176
  Constraints.MinWidth = 270
  Menu = MainMenu1
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    262
    122)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 250
    Top = 110
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 103
    Width = 262
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ToolBar1: TToolBar
    Left = 1
    Top = 0
    Width = 32
    Height = 29
    Align = alNone
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 1
    object ToolButton3: TToolButton
      Left = 0
      Top = 2
      Action = DataFrame.RebuildGrid
    end
  end
  object BtOK: TButton
    Left = 185
    Top = 82
    Width = 75
    Height = 21
    Action = OK
    Anchors = [akRight, akBottom]
    ModalResult = 1
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 97
    Top = 82
    Width = 75
    Height = 21
    Action = Cancel
    Anchors = [akRight, akBottom]
    ModalResult = 2
    TabOrder = 3
  end
  inline DataFrame: TK_FrameRAVectorEdit
    Left = 0
    Top = 29
    Width = 262
    Height = 51
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    inherited SGrid: TStringGrid
      Width = 262
      Height = 51
    end
  end
  object EdUName: TEdit
    Left = 40
    Top = 4
    Width = 220
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    TabOrder = 5
    OnChange = EdUNameChange
  end
  object BtApply: TButton
    Left = 4
    Top = 82
    Width = 75
    Height = 21
    Action = Apply
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 6
  end
  object MainMenu1: TMainMenu
    Left = 192
    object N1: TMenuItem
      Caption = #1042#1077#1082#1090#1086#1088' '#1076#1072#1085#1085#1099#1093
    end
    object N3: TMenuItem
      Caption = #1055#1088#1072#1074#1082#1072
    end
    object N2: TMenuItem
      Caption = #1042#1080#1076
      object RebuildGrid1: TMenuItem
        Action = DataFrame.RebuildGrid
      end
    end
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 224
    object Apply: TAction
      Caption = 'Apply'
      OnExecute = ApplyExecute
    end
    object OK: TAction
      Caption = 'OK'
      OnExecute = OKExecute
    end
    object Cancel: TAction
      Caption = 'Cancel'
      OnExecute = CancelExecute
    end
  end
end

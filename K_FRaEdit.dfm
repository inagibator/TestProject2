inherited K_FormRAEdit: TK_FormRAEdit
  Left = 402
  Top = 301
  Height = 206
  Caption = 'K_FormRAEdit'
  Constraints.MinWidth = 215
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 225
    Top = 160
    TabOrder = 3
  end
  inline FrameRAEdit: TK_FrameRAEdit
    Left = 0
    Top = 57
    Width = 238
    Height = 62
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
      Width = 238
      Height = 62
    end
    inherited BtExtEditor_1: TButton
      Left = 16
      Top = 120
    end
    inherited ActList: TActionList
      Left = 72
      Top = 112
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 238
    Height = 57
    AutoSize = True
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    EdgeBorders = [ebTop, ebBottom]
    Flat = True
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object ToolButton4: TToolButton
      Left = 0
      Top = 0
      Action = FrameRAEdit.RebuildGrid
      DropdownMenu = FrameRAEdit.PURebuildViewMenu
      Style = tbsDropDown
    end
    object ToolButton5: TToolButton
      Left = 38
      Top = 0
      Action = FrameRAEdit.TranspGrid
    end
    object ToolButton3: TToolButton
      Left = 63
      Top = 0
      Width = 5
      Caption = 'ToolButton3'
      ImageIndex = 80
      Style = tbsSeparator
    end
    object ToolButton1: TToolButton
      Left = 68
      Top = 0
      Action = FrameRAEdit.AddRow
    end
    object ToolButton19: TToolButton
      Left = 93
      Top = 0
      Action = FrameRAEdit.InsRow
    end
    object ToolButton2: TToolButton
      Left = 118
      Top = 0
      Action = FrameRAEdit.DelRow
    end
    object ToolButton10: TToolButton
      Left = 143
      Top = 0
      Action = FrameRAEdit.ClearSelected
    end
    object ToolButton17: TToolButton
      Left = 168
      Top = 0
      Action = FrameRAEdit.AddCol
    end
    object ToolButton18: TToolButton
      Left = 193
      Top = 0
      Action = FrameRAEdit.DelCol
    end
    object ToolButton9: TToolButton
      Left = 0
      Top = 0
      Width = 5
      Action = FrameRAEdit.ScrollToFirstRow
      Wrap = True
      Style = tbsSeparator
    end
    object ToolButton11: TToolButton
      Left = 0
      Top = 29
      Action = FrameRAEdit.ScrollToFirstRow
    end
    object ToolButton12: TToolButton
      Left = 25
      Top = 29
      Action = FrameRAEdit.ScrollToPrevRow
    end
    object ToolButton13: TToolButton
      Left = 50
      Top = 29
      Action = FrameRAEdit.ScrollToNextRow
    end
    object ToolButton14: TToolButton
      Left = 75
      Top = 29
      Action = FrameRAEdit.ScrollToLastRow
    end
    object ToolButton15: TToolButton
      Left = 100
      Top = 29
      Action = FrameRAEdit.SwitchSRecordMode
    end
    object ToolButton7: TToolButton
      Left = 125
      Top = 29
      Width = 5
      Caption = 'ToolButton7'
      ImageIndex = 81
      Style = tbsSeparator
    end
    object ToolButton8: TToolButton
      Left = 130
      Top = 29
      Action = FrameRAEdit.SendFVals
    end
    object ToolButton6: TToolButton
      Left = 155
      Top = 29
      Action = FrameRAEdit.SetPasteFromClipboardMode
    end
    object ToolButton16: TToolButton
      Left = 180
      Top = 29
      Action = ViewAsMatrix
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 119
    Width = 238
    Height = 53
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      238
      53)
    object BtApply: TButton
      Left = 38
      Top = 18
      Width = 41
      Height = 21
      Action = Apply
      Anchors = [akRight, akBottom]
      TabOrder = 0
    end
    object BtCancel: TButton
      Left = 87
      Top = 5
      Width = 74
      Height = 21
      Action = Cancel
      Anchors = [akRight, akBottom]
      ModalResult = 2
      TabOrder = 1
    end
    object BtCancelToAll: TButton
      Left = 87
      Top = 30
      Width = 74
      Height = 21
      Action = CancelToAll
      Anchors = [akRight, akBottom]
      ModalResult = 2
      TabOrder = 2
    end
    object BtOK: TButton
      Left = 166
      Top = 5
      Width = 72
      Height = 21
      Action = OK
      Anchors = [akRight, akBottom]
      ModalResult = 1
      TabOrder = 3
    end
    object BtOKToAll: TButton
      Left = 167
      Top = 30
      Width = 71
      Height = 21
      Action = OKToAll
      Anchors = [akRight, akBottom]
      ModalResult = 1
      TabOrder = 4
    end
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Top = 312
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
    object OKToAll: TAction
      Caption = 'OK to All'
      OnExecute = OKToAllExecute
    end
    object CancelToAll: TAction
      Caption = 'Cancel to All'
      OnExecute = CancelToAllExecute
    end
    object ViewAsMatrix: TAction
      Caption = 'ViewAsMatrix'
      ImageIndex = 162
      Visible = False
      OnExecute = ViewAsMatrixExecute
    end
  end
end

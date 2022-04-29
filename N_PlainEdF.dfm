inherited N_PlainEditorForm: TN_PlainEditorForm
  Left = 430
  Top = 328
  Width = 256
  Height = 189
  Caption = 'N_PlainEditorForm'
  Menu = MainMenu1
  OldCreateOrder = True
  OnShow = FormShow
  DesignSize = (
    248
    143)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 238
    Top = 121
    TabOrder = 5
  end
  object Memo: TMemo
    Left = 0
    Top = 29
    Width = 248
    Height = 73
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
    OnKeyDown = MemoKeyDown
    OnMouseDown = MemoMouseDown
  end
  object bnCancel: TButton
    Left = 82
    Top = 106
    Width = 63
    Height = 22
    Action = ControlCancel
    Anchors = [akRight, akBottom]
    ModalResult = 2
    TabOrder = 1
  end
  object bnApply: TButton
    Left = 153
    Top = 106
    Width = 69
    Height = 22
    Action = ControlApply
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object bnOK: TButton
    Left = 12
    Top = 106
    Width = 63
    Height = 22
    Action = ControlOK
    Anchors = [akRight, akBottom]
    ModalResult = 1
    TabOrder = 3
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 248
    Height = 29
    ButtonHeight = 21
    Caption = 'ToolBar'
    TabOrder = 4
    object edRowCol: TEdit
      Left = 0
      Top = 2
      Width = 129
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 40
    object File1: TMenuItem
      Caption = 'File'
      object New1: TMenuItem
        Action = actNew
      end
      object Open1: TMenuItem
        Action = actOpen
      end
      object actOpenAsHex1: TMenuItem
        Action = actOpenAsHex
      end
      object Save1: TMenuItem
        Action = actSave
      end
      object SaveAs1: TMenuItem
        Action = actSaveAs
      end
      object Append1: TMenuItem
        Action = actAppend
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
    end
    object Search1: TMenuItem
      Caption = 'Search'
    end
    object Options1: TMenuItem
      Caption = 'Options'
      object WordWrap1: TMenuItem
        Action = actWordWrap
        AutoCheck = True
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object ShowToolBar1: TMenuItem
        Action = actToolBar
        AutoCheck = True
      end
      object VerticalScrollBar1: TMenuItem
        Action = actVerticalScrollBar
        AutoCheck = True
      end
      object HorizontalScrollBar1: TMenuItem
        Action = actHorizontalScrollBar
        AutoCheck = True
      end
      object Buttons1: TMenuItem
        Action = actButtons
        AutoCheck = True
        Checked = True
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object DosToWin1: TMenuItem
        Action = actDosToWin
      end
      object actSort1: TMenuItem
        Action = actSort
      end
      object Customize1: TMenuItem
        Caption = '&Customize'
      end
      object miViewMode: TMenuItem
        Caption = 'View As Hex'
        OnClick = miViewModeClick
      end
      object StayOnTop1: TMenuItem
        Action = actStayOnTop
        AutoCheck = True
      end
    end
  end
  object ActionList: TActionList
    Left = 40
    Top = 40
    object actWordWrap: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Word Wrap'
      OnExecute = actWordWrapExecute
    end
    object actToolBar: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Tool Bar'
      Checked = True
      OnExecute = actToolBarExecute
    end
    object actVerticalScrollBar: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Vertical ScrollBar'
      Checked = True
      OnExecute = actVerticalScrollBarExecute
    end
    object actHorizontalScrollBar: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Horizontal ScrollBar'
      OnExecute = actHorizontalScrollBarExecute
    end
    object actButtons: TAction
      Category = 'Options'
      Caption = 'Buttons'
      OnExecute = actButtonsExecute
    end
    object actNew: TAction
      Category = 'File'
      Caption = 'New'
      OnExecute = actNewExecute
    end
    object actOpen: TAction
      Category = 'File'
      Caption = 'Open ...'
      OnExecute = actOpenExecute
    end
    object actOpenAsHex: TAction
      Category = 'File'
      Caption = 'Open As Hex  ...'
      OnExecute = actOpenAsHexExecute
    end
    object actSave: TAction
      Category = 'File'
      Caption = 'Save'
      OnExecute = actSaveExecute
    end
    object actSaveAs: TAction
      Category = 'File'
      Caption = 'Save As ...'
      OnExecute = actSaveAsExecute
    end
    object actAppend: TAction
      Category = 'File'
      Caption = 'Append ...'
      OnExecute = actAppendExecute
    end
    object actDosToWin: TAction
      Category = 'Options'
      Caption = 'Dos To Win'
      OnExecute = actDosToWinExecute
    end
    object actSort: TAction
      Category = 'Options'
      Caption = 'Sort All Strings'
      OnExecute = actSortExecute
    end
    object ControlApply: TAction
      Category = 'Control'
      Caption = 'Apply'
      OnExecute = ControlApplyExecute
    end
    object ControlOK: TAction
      Category = 'Control'
      Caption = 'OK'
      OnExecute = ControlOKExecute
    end
    object ControlCancel: TAction
      Category = 'Control'
      Caption = 'Cancel'
      OnExecute = ControlCancelExecute
    end
    object actViewAsHex: TAction
      Category = 'Options'
      Caption = 'View As Hex '
      OnExecute = actViewAsHexExecute
    end
    object actViewAsText: TAction
      Category = 'Options'
      Caption = 'View As Text'
      OnExecute = actViewAsTextExecute
    end
    object actStayOnTop: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Stay On Top'
      OnExecute = actStayOnTopExecute
    end
  end
  object OpenDialog: TOpenDialog
    Left = 72
    Top = 40
  end
  object SaveDialog: TSaveDialog
    Left = 105
    Top = 41
  end
end

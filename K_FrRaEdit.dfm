object K_FrameRAEdit: TK_FrameRAEdit
  Left = 0
  Top = 0
  Width = 198
  Height = 48
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  ParentFont = False
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  OnResize = FrameResize
  object SGrid: TStringGrid
    Left = 0
    Top = 0
    Width = 198
    Height = 48
    Align = alClient
    Color = clBtnFace
    ColCount = 2
    DefaultRowHeight = 21
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goThumbTracking]
    PopupMenu = PUEditMenu
    TabOrder = 0
    OnColumnMoved = SGridColumnMoved
    OnDblClick = SGridDblClick
    OnDrawCell = SGridDrawCell
    OnGetEditMask = SGridGetEditMask
    OnGetEditText = SGridGetEditText
    OnKeyDown = SGridKeyDown
    OnKeyUp = SGridKeyUp
    OnMouseDown = SGridMouseDown
    OnMouseMove = SGridMouseMove
    OnRowMoved = SGridRowMoved
    OnSelectCell = SGridSelectCell
    OnSetEditText = SGridSetEditText
    ColWidths = (
      64
      64)
    RowHeights = (
      21
      21)
  end
  object BtExtEditor_1: TButton
    Left = 34
    Top = 5
    Width = 19
    Height = 17
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    Visible = False
    OnClick = BtExtEditor_1Click
  end
  object ActList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 3
    Top = 2
    object DelRow: TAction
      Caption = 'Delete selected'
      Hint = 'Delete selected rows'
      ImageIndex = 79
      OnExecute = DelRowExecute
    end
    object AddRow: TAction
      Caption = 'Add row'
      Hint = 'Add row'
      ImageIndex = 69
      OnExecute = AddRowExecute
    end
    object CopyToClipBoardA: TAction
      Caption = 'Copy'
      Hint = 'Copy selected to clipboard '
      ImageIndex = 12
      OnExecute = CopyToClipBoardAExecute
    end
    object CopyToClipBoard: TAction
      Caption = 'Copy'
      Hint = 'Copy selected to clipboard '
      ImageIndex = 12
      OnExecute = CopyToClipBoardExecute
    end
    object CopyToClipBoardE: TAction
      Caption = 'Copy with row and column names'
      Hint = 'Copy selected with row and column names'
      ImageIndex = 156
      OnExecute = CopyToClipBoardEExecute
    end
    object PasteFromClipBoard: TAction
      Caption = 'Paste'
      Hint = 'Paste clipboard to selected'
      ImageIndex = 13
      OnExecute = PasteFromClipBoardExecute
    end
    object TranspGrid: TAction
      Caption = 'Transpose'
      Hint = 'Transpose grid'
      ImageIndex = 76
      OnExecute = TranspGridExecute
    end
    object RebuildGrid: TAction
      Caption = 'Rebuild'
      Hint = 'Rebuild grid'
      ImageIndex = 75
      OnExecute = RebuildGridExecute
    end
    object CallEditor: TAction
      Hint = 'Call external editor ...'
      ImageIndex = 29
      OnExecute = CallEditorExecute
    end
    object DelCol: TAction
      Caption = 'Delete selected'
      Hint = 'Delete selected columns'
      ImageIndex = 78
      OnExecute = DelColExecute
    end
    object AddCol: TAction
      Caption = 'Add column'
      Hint = 'Add column'
      ImageIndex = 77
      OnExecute = AddColExecute
    end
    object Search: TAction
      Caption = 'Search ...'
      Hint = 'Search'
      ImageIndex = 11
      OnExecute = SearchExecute
    end
    object Replace: TAction
      Caption = 'Replace'
      Hint = 'Replace'
      ImageIndex = 11
      OnExecute = ReplaceExecute
    end
    object ClearSelected: TAction
      Caption = 'Clear selected'
      Hint = 'Clear selected'
      ImageIndex = 18
      OnExecute = ClearSelectedExecute
    end
    object InsRow: TAction
      Caption = 'Insert row'
      Hint = 'Insert row'
      ImageIndex = 118
      OnExecute = InsRowExecute
    end
    object InsCol: TAction
      Caption = 'Insert column'
      Hint = 'Insert column'
      ImageIndex = 119
      OnExecute = InsColExecute
    end
    object SetPasteFromClipboardMode: TAction
      Caption = 'Paste mode ...'
      Hint = 'Paste mode ...'
      ImageIndex = 113
      OnExecute = SetPasteFromClipboardModeExecute
    end
    object SendFVals: TAction
      Caption = 'Data distribution ...'
      Hint = 'Selected data distribution ...'
      ImageIndex = 114
      OnExecute = SendFValsExecute
    end
    object ScrollToNextRow: TAction
      Caption = 'Scroll to next '
      Hint = 'Scroll to next'
      ImageIndex = 152
      OnExecute = ScrollToNextRowExecute
    end
    object ScrollToPrevRow: TAction
      Caption = 'Scroll to previouse'
      Hint = 'Scroll to previouse'
      ImageIndex = 153
      OnExecute = ScrollToPrevRowExecute
    end
    object ScrollToFirstRow: TAction
      Caption = 'Scroll to first '
      Hint = 'Scroll to first'
      ImageIndex = 155
      OnExecute = ScrollToFirstRowExecute
    end
    object ScrollToLastRow: TAction
      Caption = 'Scroll to last'
      Hint = 'Scroll to last'
      ImageIndex = 154
      OnExecute = ScrollToLastRowExecute
    end
    object SwitchSRecordMode: TAction
      Caption = 'Single record mode'
      Hint = 'Single record mode'
      ImageIndex = 93
      OnExecute = SwitchSRecordModeExecute
    end
    object PopupCallEditor: TAction
      Caption = 'System editor ...'
      Hint = 'System editor call ...'
      ImageIndex = 29
    end
    object PopupCallInlineEditor: TAction
      Caption = 'Inline editor ...'
      Hint = 'Call inline editor ...'
      ImageIndex = 175
    end
    object PopupCallAttrsEditor: TAction
      Caption = 'Default attributes editor ...'
      Hint = 'Default attributes editor ...'
      ImageIndex = 19
    end
    object ShowHelp: TAction
      Caption = 'Help'
      ImageIndex = 9
      OnExecute = ShowHelpExecute
    end
    object SetColResizeByData: TAction
      Caption = 'Select columns width by data value'
      Hint = 'Select columns width by data value'
      OnExecute = SetColResizeByDataExecute
    end
    object SetColResizeByHeader: TAction
      Caption = 'Select columns width by data header'
      Hint = 'Select columns width by data header'
      OnExecute = SetColResizeByHeaderExecute
    end
    object SetColResizeCompact: TAction
      Caption = 'Select columns width by window'
      Hint = 'Select columns width by window'
      OnExecute = SetColResizeCompactExecute
    end
    object SetColResizeNormal: TAction
      Caption = 'Columns natural width'
      Hint = 'Columns natural width'
      OnExecute = SetColResizeNormalExecute
    end
    object RenameCol: TAction
      Caption = 'Rename Column'
      ImageIndex = 44
      OnExecute = RenameColExecute
    end
    object MarkAllRows: TAction
      Caption = 'Mark all rows'
      Hint = 'Mark all rows'
      ImageIndex = 236
      OnExecute = MarkAllRowsExecute
    end
    object MarkAllCols: TAction
      Caption = 'Mark all columns'
      Hint = 'Mark all columns'
      ImageIndex = 219
      OnExecute = MarkAllColsExecute
    end
    object ReverseRowsMark: TAction
      Caption = 'Reverse rows mark'
      Hint = 'Reverse rows mark'
      ImageIndex = 235
      OnExecute = ReverseRowsMarkExecute
    end
    object ReverseColsMark: TAction
      Caption = 'Reverse columns mark'
      Hint = 'Reverse columns mark'
      ImageIndex = 234
      OnExecute = ReverseColsMarkExecute
    end
  end
  object PUEditMenu: TPopupMenu
    Images = N_ButtonsForm.ButtonsList
    OnPopup = PUEditMenuPopup
    Left = 62
    Top = 3
  end
  object PURebuildViewMenu: TPopupMenu
    OnPopup = PopUpRebuildGridInfoMenu
    Left = 91
    Top = 3
    object PUMItemCompact: TMenuItem
      Action = SetColResizeCompact
      RadioItem = True
    end
    object PUMItemByData: TMenuItem
      Action = SetColResizeByData
      RadioItem = True
    end
    object PUMItemByHeader: TMenuItem
      Action = SetColResizeByHeader
      RadioItem = True
    end
    object PUMItemNormal: TMenuItem
      Action = SetColResizeNormal
      RadioItem = True
    end
  end
  object PUCopyToClipboardMenu: TPopupMenu
    OnPopup = PopUpCopyToClipBoardMenu
    Left = 128
    Top = 3
    object PUMItemCopy: TMenuItem
      Action = CopyToClipBoard
      RadioItem = True
    end
    object PUMItemECopy: TMenuItem
      Action = CopyToClipBoardE
      RadioItem = True
    end
  end
  object Timer: TTimer
    Enabled = False
    Left = 161
    Top = 3
  end
end

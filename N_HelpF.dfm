object N_HelpForm: TN_HelpForm
  Left = 63
  Top = 582
  Width = 453
  Height = 250
  Caption = 'Help Window'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 445
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 77
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    List = True
    ShowCaptions = True
    TabOrder = 0
    object tbContent: TToolButton
      Left = 0
      Top = 2
      Hint = 'Show Help Content'
      AutoSize = True
      Caption = ' Content '
      DropdownMenu = ContentMenu
      ParentShowHint = False
      ShowHint = True
    end
    object tbSeeAlso: TToolButton
      Left = 54
      Top = 2
      Hint = 'See Also'
      AutoSize = True
      Caption = ' See Also '
      DropdownMenu = SeeAlsoMenu
      ParentShowHint = False
      ShowHint = True
    end
    object tbHistory: TToolButton
      Left = 113
      Top = 2
      AutoSize = True
      Caption = ' History '
      DropdownMenu = HistoryMenu
      ParentShowHint = False
      ShowHint = True
    end
    object tbOther: TToolButton
      Left = 162
      Top = 2
      Hint = 'Help Params and Actions'
      AutoSize = True
      Caption = ' Other '
      DropdownMenu = OtherMenu
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton1: TToolButton
      Left = 205
      Top = 2
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object bnCopyToClipboard: TToolButton
      Left = 213
      Top = 2
      Hint = 'Copy Topic to Clipboard'
      AutoSize = True
      ImageIndex = 12
      OnClick = bnCopyToClipboardClick
    end
  end
  object RichEdit: TRichEdit
    Left = 0
    Top = 29
    Width = 445
    Height = 187
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'RichEdit')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object ActionList1: TActionList
    Left = 64
    Top = 48
  end
  object ContentMenu: TPopupMenu
    HelpContext = 3
    Left = 24
    Top = 88
  end
  object SeeAlsoMenu: TPopupMenu
    Left = 64
    Top = 88
    object asdasd1: TMenuItem
      Caption = 'asdasd'
    end
  end
  object HistoryMenu: TPopupMenu
    Left = 104
    Top = 88
  end
  object OtherMenu: TPopupMenu
    Left = 144
    Top = 88
    object MenuItem2: TMenuItem
      Caption = 'Not yet'
    end
  end
end

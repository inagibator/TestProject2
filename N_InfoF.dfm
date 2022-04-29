object N_InfoForm: TN_InfoForm
  Left = 193
  Top = 248
  Width = 388
  Height = 447
  Caption = 'N_InfoForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 14
  object Memo: TMemo
    Left = 0
    Top = 29
    Width = 380
    Height = 380
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 380
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 1
    object tbClearLines: TToolButton
      Left = 0
      Top = 2
      Hint = 'Clear all lines'
      Caption = 'tbClearLines'
      ImageIndex = 18
      ParentShowHint = False
      ShowHint = True
      OnClick = tbClearLinesClick
    end
    object ToolButton2: TToolButton
      Left = 25
      Top = 2
      Hint = 'Clear file a_info.txt'
      Caption = 'ToolButton2'
      ImageIndex = 133
      ParentShowHint = False
      ShowHint = True
      OnClick = ToolButton2Click
    end
    object ToolButton3: TToolButton
      Left = 50
      Top = 2
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 58
      Top = 2
      Hint = 'Add to file a_info.txt'
      Caption = 'ToolButton4'
      ImageIndex = 5
      ParentShowHint = False
      ShowHint = True
      OnClick = ToolButton4Click
    end
    object ToolButton5: TToolButton
      Left = 83
      Top = 2
      Hint = 'Read from file a_info.txt'
      Caption = 'ToolButton5'
      ImageIndex = 4
      ParentShowHint = False
      ShowHint = True
      OnClick = ToolButton5Click
    end
    object ToolButton6: TToolButton
      Left = 108
      Top = 2
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object tbWrap: TToolButton
      Left = 116
      Top = 2
      Caption = 'tbWrap'
      ImageIndex = 76
      Style = tbsCheck
      OnClick = tbWrapClick
    end
  end
end

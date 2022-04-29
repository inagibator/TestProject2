inherited N_CMDevStatForm: TN_CMDevStatForm
  Left = 490
  Top = 445
  Width = 628
  Height = 357
  Caption = 'Capturing statistics'
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 600
    Top = 300
    TabOrder = 2
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 620
    Height = 26
    AutoSize = True
    ButtonHeight = 24
    ButtonWidth = 124
    Caption = 'ToolBar'
    Flat = True
    Images = N_ButtonsForm.ButtonsList
    List = True
    ParentShowHint = False
    ShowCaptions = True
    ShowHint = True
    TabOrder = 0
    object ToolButton2: TToolButton
      Left = 0
      Top = 0
      Hint = 'Transpose table view'
      Action = RAEdFrame.TranspGrid
      AutoSize = True
      Caption = '  Transpose view  '
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton6: TToolButton
      Left = 120
      Top = 0
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 81
      Style = tbsDivider
    end
    object ToolButton1: TToolButton
      Left = 128
      Top = 0
      Hint = 'Copy selection to clipboard'
      Action = RAEdFrame.CopyToClipBoard
      AutoSize = True
      Caption = '  Copy  '
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton3: TToolButton
      Left = 197
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 80
      Style = tbsDivider
    end
    object ToolButton4: TToolButton
      Left = 205
      Top = 0
      Hint = 'Remove selected data'
      Action = RAEdFrame.DelRow
      Caption = '  Remove selected  '
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton5: TToolButton
      Left = 329
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 80
      Style = tbsDivider
    end
    object Button2: TButton
      Left = 337
      Top = 0
      Width = 60
      Height = 24
      Action = aCancel
      TabOrder = 1
    end
    object Button1: TButton
      Left = 397
      Top = 0
      Width = 60
      Height = 24
      Action = aOK
      TabOrder = 0
    end
  end
  inline RAEdFrame: TK_FrameRAEdit
    Left = 0
    Top = 26
    Width = 620
    Height = 297
    Align = alClient
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
      Width = 620
      Height = 297
    end
  end
  object ActionList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 504
    object aCancel: TAction
      Caption = 'Cancel'
      Hint = 'Exit without data changing'
      OnExecute = aCancelExecute
    end
    object aOK: TAction
      Caption = 'OK'
      Hint = 'Save all changed data and exit'
      OnExecute = aOKExecute
    end
  end
end

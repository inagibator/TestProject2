inherited K_FormMVDeb: TK_FormMVDeb
  Left = 371
  Top = 381
  Width = 619
  Height = 461
  Caption = 'K_FormMVDeb'
  Menu = MainMenu1
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyUp = EditKeyUpEvent
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter [0]
    Left = 0
    Top = 329
    Width = 611
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  inherited BFMinBRPanel: TPanel
    Left = 599
    Top = 395
    TabOrder = 3
  end
  object InfoMemo: TMemo
    Left = 0
    Top = 332
    Width = 611
    Height = 56
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 27
    Width = 611
    Height = 302
    Align = alTop
    TabOrder = 1
    OnChange = PageControl1Change
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 611
    Height = 27
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object ToolButton10: TToolButton
      Left = 0
      Top = 2
      Action = ActionNew
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton1: TToolButton
      Left = 25
      Top = 2
      Action = ActionOpen
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton2: TToolButton
      Left = 50
      Top = 2
      Action = ActionSave
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton5: TToolButton
      Left = 75
      Top = 2
      Width = 4
      Caption = 'ToolButton5'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object ToolButton3: TToolButton
      Left = 79
      Top = 2
      Action = ActionCompile
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton6: TToolButton
      Left = 104
      Top = 2
      Width = 4
      Caption = 'ToolButton6'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 108
      Top = 2
      Action = ActionRun
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton7: TToolButton
      Left = 133
      Top = 2
      Action = ActionStepOver
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton8: TToolButton
      Left = 158
      Top = 2
      Action = ActionStepInto
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton9: TToolButton
      Left = 183
      Top = 2
      Action = ActionStepOut
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton13: TToolButton
      Left = 208
      Top = 2
      Action = ActionBreak
    end
    object ToolButton12: TToolButton
      Left = 233
      Top = 2
      Width = 4
      Caption = 'ToolButton12'
      ImageIndex = 12
      Style = tbsSeparator
    end
    object ToolButton11: TToolButton
      Left = 237
      Top = 2
      Action = ActionClose
      ParentShowHint = False
      ShowHint = True
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 388
    Width = 611
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ProMemo: TMemo
    Left = 472
    Top = 64
    Width = 105
    Height = 41
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'Prototype of '
      'all Memo')
    ParentFont = False
    TabOrder = 4
    Visible = False
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 536
    object ActionRun: TAction
      Caption = 'Run'
      Enabled = False
      Hint = 'Run Selected Unit Program Item'
      ImageIndex = 108
      OnExecute = ActionRunExecute
    end
    object ActionOpen: TAction
      Caption = 'Open'
      Hint = 'Open Existing Unit Text'
      ImageIndex = 106
      OnExecute = ActionOpenExecute
    end
    object ActionImport: TAction
      Caption = 'Import'
      Hint = 'Import Text From File'
      ImageIndex = 1
      OnExecute = ActionImportExecute
    end
    object ActionCompile: TAction
      Caption = 'Compile'
      Enabled = False
      Hint = 'Compile Selected Unit'
      ImageIndex = 101
      OnExecute = ActionCompileExecute
    end
    object ActionExport: TAction
      Caption = 'Export'
      Enabled = False
      Hint = 'Export Text To File'
      ImageIndex = 2
      OnExecute = ActionExportExecute
    end
    object ActionSave: TAction
      Caption = 'Save'
      Enabled = False
      Hint = 'Save Text to Existing Unit'
      ImageIndex = 3
      OnExecute = ActionSaveExecute
    end
    object ActionNew: TAction
      Caption = 'New'
      Hint = 'Open New Text Edit'
      ImageIndex = 0
      OnExecute = ActionNewExecute
    end
    object ActionClose: TAction
      Caption = 'Close'
      Enabled = False
      Hint = 'Close Selected Text Edit'
      ImageIndex = 18
      OnExecute = ActionCloseExecute
    end
    object ActionBreak: TAction
      Caption = 'ProgramReset'
      Enabled = False
      Hint = 'Break Running Program Item'
      ImageIndex = 107
      Visible = False
      OnExecute = ActionBreakExecute
    end
    object ActionStepOver: TAction
      Caption = 'Step Over'
      Enabled = False
      Hint = 'Step Over'
      ImageIndex = 104
      OnExecute = ActionStepOverExecute
    end
    object ActionStepInto: TAction
      Caption = 'Trace Into'
      Enabled = False
      Hint = 'Step Into'
      ImageIndex = 102
      OnExecute = ActionStepIntoExecute
    end
    object ActionStepOut: TAction
      Caption = 'Run Until Return'
      Enabled = False
      Hint = 'Run Until Return'
      ImageIndex = 103
      Visible = False
      OnExecute = ActionStepOutExecute
    end
    object ActionParams: TAction
      Caption = 'Trace Parameters ...'
      Hint = 'Settings'
      ImageIndex = 30
      OnExecute = ActionParamsExecute
    end
  end
  object MainMenu1: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 568
    object File1: TMenuItem
      Caption = 'File'
      object New1: TMenuItem
        Action = ActionNew
        Hint = 'Edit New Unit'
      end
      object Open1: TMenuItem
        Action = ActionOpen
      end
      object Save1: TMenuItem
        Action = ActionSave
      end
      object Close1: TMenuItem
        Action = ActionClose
        Hint = 'Close Edit Window'
      end
      object Import1: TMenuItem
        Action = ActionImport
      end
      object Export1: TMenuItem
        Action = ActionExport
        Hint = 'Export Unit text to File'
      end
    end
    object Unit1: TMenuItem
      Caption = 'Unit'
      object Compile1: TMenuItem
        Action = ActionCompile
        Hint = 'Compile Unit'
      end
      object Run1: TMenuItem
        Action = ActionRun
      end
      object StepOver1: TMenuItem
        Action = ActionStepOver
      end
      object TraceInto1: TMenuItem
        Action = ActionStepInto
      end
      object RunUntilReturn1: TMenuItem
        Action = ActionStepOut
      end
      object ProgramReset1: TMenuItem
        Action = ActionBreak
      end
      object TraceMode1: TMenuItem
        Action = ActionParams
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Program Files( *.spl )|*.spl|All files (*.*)|*.*'
    Left = 504
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Program Files (*.spl)|*.spl|All Files (*.*)|*.*'
    Left = 472
  end
end

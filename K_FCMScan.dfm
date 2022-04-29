inherited K_FormCMScan: TK_FormCMScan
  Left = 424
  Top = 284
  BorderStyle = bsToolWindow
  Caption = 'MediaSuite Scanner'
  ClientHeight = 73
  ClientWidth = 394
  FormStyle = fsStayOnTop
  Menu = MainMenu1
  OldCreateOrder = True
  Position = poScreenCenter
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnHide = FormHide
  OnShow = FormShow
  ExplicitWidth = 400
  ExplicitHeight = 122
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 383
    Top = 61
    Width = 9
    ExplicitLeft = 383
    ExplicitTop = 61
    ExplicitWidth = 9
  end
  object ScanCaptToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 394
    Height = 54
    ButtonHeight = 50
    ButtonWidth = 51
    Caption = 'ToolBar2'
    Color = clBtnFace
    EdgeInner = esNone
    EdgeOuter = esNone
    Indent = 2
    ParentColor = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    Wrapable = False
    object ToolButton15: TToolButton
      Left = 2
      Top = 0
      Action = N_CMResForm.aDebAction1
    end
    object ToolButton16: TToolButton
      Left = 53
      Top = 0
      Action = N_CMResForm.aDebAction2
    end
    object ToolButton17: TToolButton
      Left = 104
      Top = 0
      Action = N_CMResForm.aGoToExit
    end
    object ToolButton6: TToolButton
      Left = 155
      Top = 0
      Caption = 'ToolButton6'
      ImageIndex = 4
    end
    object ToolButton19: TToolButton
      Left = 206
      Top = 0
      Caption = 'ToolButton19'
      ImageIndex = 5
    end
    object ToolButton20: TToolButton
      Left = 257
      Top = 0
      Caption = 'ToolButton20'
      ImageIndex = 6
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 54
    Width = 394
    Height = 19
    Panels = <>
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 16
    object File1: TMenuItem
      Caption = 'File'
      object ChangeDataPath1: TMenuItem
        Action = aChangeDataPath
      end
      object Offlinemode1: TMenuItem
        Action = aOfflineMode
        AutoCheck = True
      end
      object PreviousCaptureResults1: TMenuItem
        Action = aPrevCaptResultsRecovery
      end
      object WEBSettings1: TMenuItem
        Action = aWEBSettings
      end
      object Exit1: TMenuItem
        Action = aExit
      end
    end
    object Capture1: TMenuItem
      Caption = 'Capture'
      object SetupAdvanced1: TMenuItem
        Action = N_CMResForm.aCapCaptDevSetup
      end
      object FootPedalSetup1: TMenuItem
        Action = N_CMResForm.aCapFootPedalSetup
      end
      object N1: TMenuItem
        Caption = '-'
      end
    end
    object Devices1: TMenuItem
      Caption = 'Devices'
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Caption = 'About Media Suite Scanner ...'
        Hint = 'About window'
      end
    end
  end
  object ActTimer: TTimer
    Enabled = False
    OnTimer = ActTimerTimer
    Left = 64
    Top = 16
  end
  object BigIcons: TImageList
    Left = 112
    Top = 16
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 160
    Top = 16
    object SetupMediaSuiteScanner1: TMenuItem
      Action = aSetupMediaSuiteScanner
    end
    object About2: TMenuItem
      Caption = 'About Media Suite Scanner ...'
      Hint = 'About window'
    end
    object CreateCMScanexeDistributive1: TMenuItem
      Action = N_CMResForm.aDeb2CreateScanExeDistr
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object QuitMediaSuiteScanner1: TMenuItem
      Caption = 'Quit Media Suite Scanner'
      OnClick = QuitMediaSuiteScanner1Click
    end
  end
  object ActionList1: TActionList
    Left = 218
    Top = 16
    object aPrevCaptResultsRecovery: TAction
      Caption = 'Recovery ...'
      Hint = 'Previous capture results recovery'
      OnExecute = aPrevCaptResultsRecoveryExecute
    end
    object aExit: TAction
      Caption = 'Exit'
      OnExecute = aExitExecute
    end
    object aChangeDataPath: TAction
      Caption = 'Change Data Path ...'
      OnExecute = aChangeDataPathExecute
    end
    object aSetupMediaSuiteScanner: TAction
      Caption = 'Setup Media Suite Scanner ...'
      OnExecute = aSetupMediaSuiteScannerExecute
    end
    object aOfflineMode: TAction
      AutoCheck = True
      Caption = 'Offline mode'
      Enabled = False
      OnExecute = aOfflineModeExecute
    end
    object aWEBSettings: TAction
      Caption = 'WEB Settings'
      OnExecute = aWEBSettingsExecute
    end
  end
  object TimerWEBDav: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = TimerWEBDavTimer
    Left = 264
    Top = 16
  end
  object tiMain: TTrayIcon
    BalloonTimeout = 5000
    PopupMenu = PopupMenu1
    Visible = True
    OnDblClick = tiMainDblClick
    OnMouseUp = tiMainMouseUp
    Left = 288
    Top = 8
  end
  object eventsMain: TApplicationEvents
    OnMinimize = eventsMainMinimize
    OnRestore = eventsMainRestore
    Left = 248
    Top = 8
  end
end

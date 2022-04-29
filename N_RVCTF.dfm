object N_RastVCTForm: TN_RastVCTForm
  Left = 266
  Top = 415
  Width = 320
  Height = 221
  Caption = 'N_RastVCTForm'
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object RVCTFToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 312
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'RVCTFToolBar1'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Action = RFrame.aShowOptionsForm
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton2: TToolButton
      Left = 25
      Top = 2
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 20
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 33
      Top = 2
      Hint = '(Old) View Full Image and Adjust Form Size'
      Action = RFrame.aInitFrame
      ParentShowHint = False
      ShowHint = True
    end
    object tbRefresh: TToolButton
      Left = 58
      Top = 2
      Action = RFrame.aRedrawFrame
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton5: TToolButton
      Left = 83
      Top = 2
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 39
      Style = tbsSeparator
    end
    object ToolButton6: TToolButton
      Left = 91
      Top = 2
      Action = RFrame.aShowCompBorders
      AllowAllUp = True
      Grouped = True
      ParentShowHint = False
      ShowHint = True
      Style = tbsCheck
    end
    object ToolButton3: TToolButton
      Left = 116
      Top = 2
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 56
      Style = tbsSeparator
    end
    object ToolButton7: TToolButton
      Left = 124
      Top = 2
      Hint = 'Fit in Window'
      Action = RFrame.aFitInWindow
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton8: TToolButton
      Left = 149
      Top = 2
      Hint = 'Set Resolution (+Shift - Scr or Prn, +Ctrl FullBufSize)'
      Action = RFrame.aFitInCompSize
      ImageIndex = 213
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton9: TToolButton
      Left = 174
      Top = 2
      Hint = 'Copy Raster To Clipboard'
      Action = RFrame.aCopyToClipboard
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton12: TToolButton
      Left = 199
      Top = 2
      Action = RFrame.aFullScreen
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton10: TToolButton
      Left = 224
      Top = 2
      Action = aShowRubberRect
      ParentShowHint = False
      ShowHint = True
    end
  end
  inline RFrame: TN_Rast1Frame
    Left = 0
    Top = 29
    Width = 312
    Height = 135
    HelpType = htKeyword
    Align = alClient
    Constraints.MinHeight = 104
    Constraints.MinWidth = 78
    Color = clBtnFace
    ParentColor = False
    TabOrder = 1
    inherited PaintBox: TPaintBox
      Width = 296
      Height = 119
    end
    inherited HScrollBar: TScrollBar
      Top = 119
      Width = 312
    end
    inherited VScrollBar: TScrollBar
      Left = 296
      Height = 119
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 164
    Width = 312
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object RVCTFActionList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 144
    Top = 40
    object aShowRubberRect: TAction
      AutoCheck = True
      Caption = 'Show Rubber Rect'
      Hint = 'Show Rubber Rect'
      ImageIndex = 75
      OnExecute = aShowRubberRectExecute
    end
  end
end

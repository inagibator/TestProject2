inherited K_FormCMStudyTemplateChange1: TK_FormCMStudyTemplateChange1
  Left = 473
  Top = 175
  Width = 800
  Height = 600
  Caption = 'K_FormCMStudyTemplateChange1'
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 772
    Top = 549
  end
  inline TemplateFrame: TN_CMREdit3Frame
    Left = 2
    Top = 3
    Width = 780
    Height = 495
    Anchors = [akLeft, akTop, akRight, akBottom]
    Constraints.MinHeight = 80
    Constraints.MinWidth = 70
    Color = clBtnShadow
    ParentBackground = False
    ParentColor = False
    TabOrder = 1
    inherited FrameRightCaption: TLabel
      Left = 660
    end
    inherited FinishEditing: TSpeedButton
      Left = 759
    end
    inherited RFrame: TN_MapEdFrame
      Left = 0
      Top = 0
      Width = 780
      Height = 495
      Align = alClient
      inherited PaintBox: TPaintBox
        Width = 764
        Height = 479
        OnMouseDown = RFramePaintBoxMouseDown
      end
      inherited HScrollBar: TScrollBar
        Top = 479
        Width = 780
      end
      inherited VScrollBar: TScrollBar
        Left = 764
        Height = 479
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 542
    Width = 784
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object BtOK: TButton
    Left = 608
    Top = 508
    Width = 80
    Height = 25
    Hint = 'Save results and exit'
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 696
    Top = 508
    Width = 80
    Height = 25
    Hint = 'Exit without saving results'
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
  end
  object BtUndo: TButton
    Left = 320
    Top = 508
    Width = 80
    Height = 25
    Hint = 'Undo last item order setting'
    Anchors = [akLeft, akBottom]
    Caption = 'Undo'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = BtUndoClick
  end
  object BtReset: TButton
    Left = 232
    Top = 508
    Width = 80
    Height = 25
    Hint = 'Reset template fill order'
    Anchors = [akLeft, akBottom]
    Caption = 'Reset'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    OnClick = BtResetClick
  end
  object BtSetCurOrder: TButton
    Left = 118
    Top = 508
    Width = 106
    Height = 25
    Hint = 'Set template current using fill order'
    Anchors = [akLeft, akBottom]
    Caption = 'Set current order'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    OnClick = BtSetCurOrderClick
  end
  object BtSetInitOrder: TButton
    Left = 6
    Top = 508
    Width = 106
    Height = 25
    Hint = 'Set template initial fill order'
    Anchors = [akLeft, akBottom]
    Caption = 'Set initial order'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    OnClick = BtSetInitOrderClick
  end
end

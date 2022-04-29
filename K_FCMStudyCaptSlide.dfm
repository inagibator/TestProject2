inherited K_FormCMStudyCaptSlide: TK_FormCMStudyCaptSlide
  Left = 380
  Top = 276
  Width = 649
  Height = 353
  Caption = 'Preview last'
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 622
    Top = 302
  end
  inline RFrame: TN_Rast1Frame
    Left = 3
    Top = 2
    Width = 629
    Height = 239
    HelpType = htKeyword
    Anchors = [akLeft, akTop, akRight, akBottom]
    Constraints.MinHeight = 56
    Constraints.MinWidth = 56
    Color = clBtnFace
    ParentColor = False
    TabOrder = 1
    inherited PaintBox: TPaintBox
      Width = 613
      Height = 223
      OnMouseDown = RFramePaintBoxMouseDown
    end
    inherited HScrollBar: TScrollBar
      Top = 223
      Width = 629
    end
    inherited VScrollBar: TScrollBar
      Left = 613
      Height = 223
    end
  end
  object BtCancel: TButton
    Left = 531
    Top = 282
    Width = 94
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Reject image'
    ModalResult = 2
    TabOrder = 2
    OnClick = BtCancelClick
  end
  object RGPreviewTimeout: TRadioGroup
    Left = 16
    Top = 252
    Width = 497
    Height = 46
    Anchors = [akLeft, akRight, akBottom]
    Caption = '  Display Preview (seconds)  '
    Columns = 4
    Items.Strings = (
      'Indefinitely'
      '5'
      '10'
      '20')
    TabOrder = 3
    OnClick = RGPreviewTimeoutClick
  end
  object BtOK: TButton
    Left = 531
    Top = 250
    Width = 94
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    ModalResult = 1
    TabOrder = 4
    OnClick = BtOKClick
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = TimerTimer
    Left = 8
    Top = 176
  end
end

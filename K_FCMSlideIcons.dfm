inherited K_FormCMSlideIcons: TK_FormCMSlideIcons
  Left = 519
  Top = 210
  Width = 446
  Height = 273
  Caption = 'Objects deletion confirmation'
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage [0]
    Left = 16
    Top = 8
    Width = 32
    Height = 32
  end
  object LbHead: TLabel [1]
    Left = 64
    Top = 8
    Width = 316
    Height = 13
    Alignment = taCenter
    Caption = 
      '_Do you confirm that you really want to delete (n) selected obje' +
      'cts?'
    WordWrap = True
  end
  inherited BFMinBRPanel: TPanel
    Left = 426
    Top = 244
    TabOrder = 3
  end
  object BtOK: TButton
    Left = 268
    Top = 204
    Width = 74
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Yes'
    ModalResult = 1
    TabOrder = 0
  end
  object BtCancel: TButton
    Left = 356
    Top = 204
    Width = 74
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'No'
    ModalResult = 2
    TabOrder = 1
  end
  object PnSlides: TPanel
    Left = 8
    Top = 46
    Width = 423
    Height = 151
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    Caption = 'PnSlides'
    TabOrder = 2
    inline ThumbsRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 421
      Height = 149
      HelpType = htKeyword
      Align = alClient
      Constraints.MinHeight = 56
      Constraints.MinWidth = 56
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 405
        Height = 133
      end
      inherited HScrollBar: TScrollBar
        Top = 133
        Width = 421
      end
      inherited VScrollBar: TScrollBar
        Left = 405
        Height = 133
      end
    end
  end
end

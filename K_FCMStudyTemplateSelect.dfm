inherited K_FormCMStudyTemplateSelect: TK_FormCMStudyTemplateSelect
  Left = 478
  Top = 356
  Width = 528
  Height = 181
  Caption = 'New Study'
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 508
    Top = 138
    TabOrder = 3
  end
  object BtOK: TButton
    Left = 348
    Top = 113
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object BtCancel: TButton
    Left = 436
    Top = 113
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object PnSlides: TPanel
    Left = 6
    Top = 5
    Width = 509
    Height = 73
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    Caption = 'PnSlides'
    TabOrder = 2
    inline ThumbsRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 507
      Height = 71
      HelpType = htKeyword
      Align = alClient
      Constraints.MinHeight = 56
      Constraints.MinWidth = 56
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      OnDblClick = ThumbsRFrameDblClick
      inherited PaintBox: TPaintBox
        Width = 491
        Height = 55
        OnDblClick = ThumbsRFrameDblClick
      end
      inherited HScrollBar: TScrollBar
        Top = 55
        Width = 507
      end
      inherited VScrollBar: TScrollBar
        Left = 491
        Height = 55
      end
    end
  end
  object GBStudyName: TGroupBox
    Left = 8
    Top = 88
    Width = 193
    Height = 49
    Anchors = [akLeft, akRight, akBottom]
    Caption = ' Study name (optional) '
    TabOrder = 4
    DesignSize = (
      193
      49)
    object EdStudyName: TEdit
      Left = 8
      Top = 18
      Width = 177
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'None'
    end
  end
  object GBSudyColor: TGroupBox
    Left = 210
    Top = 88
    Width = 121
    Height = 49
    Anchors = [akRight, akBottom]
    Caption = ' Colour Label '
    TabOrder = 5
    object CmBStudyColor: TComboBox
      Left = 8
      Top = 18
      Width = 105
      Height = 19
      Style = csOwnerDrawFixed
      ItemHeight = 13
      TabOrder = 0
      OnDrawItem = CmBStudyColorDrawItem
    end
  end
  object BtChange: TButton
    Left = 348
    Top = 85
    Width = 163
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Change template items order'
    TabOrder = 6
    Visible = False
    OnClick = BtChangeClick
  end
end

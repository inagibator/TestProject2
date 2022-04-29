object N_AffCoefs4Form: TN_AffCoefs4Form
  Left = 320
  Top = 152
  Width = 336
  Height = 189
  Caption = 'N_AffCoefs4Form'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    328
    151)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 4
    Top = 144
    Width = 36
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = 'Cy, Sy :'
  end
  object Label2: TLabel
    Left = 3
    Top = 118
    Width = 36
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = 'Cx, Sx :'
  end
  object bnApply: TButton
    Left = 278
    Top = 113
    Width = 50
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Apply'
    TabOrder = 0
    OnClick = bnApplyClick
  end
  object bnOK: TButton
    Left = 225
    Top = 139
    Width = 50
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 1
    OnClick = bnOKClick
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 328
    Height = 105
    ActivePage = tsTwoRects
    Align = alTop
    TabOrder = 2
    object tsTwoRects: TTabSheet
      Caption = 'Two Rects'
      object edInpRect: TLabeledEdit
        Left = 51
        Top = 10
        Width = 265
        Height = 21
        EditLabel.Width = 47
        EditLabel.Height = 13
        EditLabel.Caption = 'Inp Rect :'
        LabelPosition = lpLeft
        TabOrder = 0
      end
      object edOutRect: TLabeledEdit
        Left = 51
        Top = 40
        Width = 265
        Height = 21
        EditLabel.Width = 49
        EditLabel.Height = 13
        EditLabel.Caption = 'Out Rect :'
        LabelPosition = lpLeft
        TabOrder = 1
      end
    end
    object tsStandard: TTabSheet
      Caption = 'Standard'
      ImageIndex = 1
      object rgConvertionType: TRadioGroup
        Left = 2
        Top = 0
        Width = 127
        Height = 73
        Caption = 'Convertion Type'
        Items.Strings = (
          'Identity'
          'Y Reverse')
        TabOrder = 0
        OnClick = rgConvertionTypeClick
      end
    end
  end
  object edCySy: TEdit
    Left = 46
    Top = 139
    Width = 155
    Height = 21
    Anchors = [akRight, akBottom]
    TabOrder = 3
    Text = ' 1.0   0.0'
  end
  object edCxSx: TEdit
    Left = 46
    Top = 113
    Width = 155
    Height = 21
    Anchors = [akRight, akBottom]
    TabOrder = 4
    Text = ' 1.0   0.0'
  end
  object bnCancel: TButton
    Left = 279
    Top = 139
    Width = 49
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = bnCancelClick
  end
  object bnRecalc: TButton
    Left = 225
    Top = 113
    Width = 50
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Recalc'
    TabOrder = 6
    OnClick = bnRecalcClick
  end
end

object N_NLConvForm: TN_NLConvForm
  Left = 65
  Top = 523
  Width = 272
  Height = 207
  Caption = 'Non Linear Convertor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 150
    Width = 264
    Height = 19
    Panels = <>
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 264
    Height = 150
    ActivePage = tsMain
    Align = alClient
    TabOrder = 1
    OnChange = PageControlChange
    object tsMain: TTabSheet
      Caption = 'Main'
      object rgRectsToChange: TRadioGroup
        Left = 2
        Top = 0
        Width = 84
        Height = 91
        Caption = ' Change Rects '
        ItemIndex = 0
        Items.Strings = (
          'Src, Dst'
          'Dst, Src'
          'Src+Dst'
          'All Rects')
        TabOrder = 0
      end
      object cbFixedCenter: TCheckBox
        Left = 95
        Top = 29
        Width = 89
        Height = 17
        Caption = 'Fixed Center'
        TabOrder = 1
      end
      object bnConvert: TButton
        Left = 94
        Top = 5
        Width = 30
        Height = 21
        Caption = 'DO!'
        TabOrder = 2
        OnClick = bnConvertClick
      end
      object bnShowMenu: TButton
        Left = 130
        Top = 5
        Width = 26
        Height = 21
        Caption = '...'
        TabOrder = 3
        OnClick = bnShowMenuClick
      end
    end
    object tsView: TTabSheet
      Caption = 'View'
      ImageIndex = 3
      object cbStayOnTop: TCheckBox
        Left = 6
        Top = 2
        Width = 89
        Height = 17
        Caption = 'Stay On Top'
        TabOrder = 0
        OnClick = cbStayOnTopClick
      end
      object cbHideRects: TCheckBox
        Left = 6
        Top = 35
        Width = 89
        Height = 17
        Caption = 'Hide Rects'
        TabOrder = 1
        OnClick = RedrawRectsAndMatr
      end
      object cbMatrIsVisible: TCheckBox
        Left = 6
        Top = 19
        Width = 89
        Height = 17
        Caption = 'Matr Is Visible'
        TabOrder = 2
        OnClick = RedrawRectsAndMatr
      end
    end
    object tsCoords: TTabSheet
      Caption = 'Coords'
      ImageIndex = 1
      object edNXNY: TLabeledEdit
        Left = 46
        Top = 2
        Width = 65
        Height = 21
        EditLabel.Width = 42
        EditLabel.Height = 13
        EditLabel.Caption = 'NX NY : '
        LabelPosition = lpLeft
        TabOrder = 0
        OnKeyDown = edNXNYKeyDown
      end
      object edEnvRect: TLabeledEdit
        Left = 31
        Top = 29
        Width = 162
        Height = 21
        EditLabel.Width = 28
        EditLabel.Height = 13
        EditLabel.Caption = 'Env : '
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 1
      end
      object edSrcRect: TLabeledEdit
        Left = 31
        Top = 54
        Width = 162
        Height = 21
        EditLabel.Width = 25
        EditLabel.Height = 13
        EditLabel.Caption = 'Src : '
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 2
      end
      object edDstRect: TLabeledEdit
        Left = 31
        Top = 80
        Width = 162
        Height = 21
        EditLabel.Width = 25
        EditLabel.Height = 13
        EditLabel.Caption = 'Dst : '
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 3
      end
    end
    object tsColors: TTabSheet
      Caption = 'Colors'
      ImageIndex = 2
      object edEnvRectAttr: TLabeledEdit
        Left = 32
        Top = 28
        Width = 119
        Height = 21
        EditLabel.Width = 28
        EditLabel.Height = 13
        EditLabel.Caption = 'Env : '
        LabelPosition = lpLeft
        TabOrder = 0
        OnKeyDown = edRedrawOnKeyDown
      end
      object edSrcRectAttr: TLabeledEdit
        Left = 32
        Top = 53
        Width = 119
        Height = 21
        EditLabel.Width = 25
        EditLabel.Height = 13
        EditLabel.Caption = 'Src : '
        LabelPosition = lpLeft
        TabOrder = 1
        OnKeyDown = edRedrawOnKeyDown
      end
      object edDstRectAttr: TLabeledEdit
        Left = 32
        Top = 79
        Width = 119
        Height = 21
        EditLabel.Width = 25
        EditLabel.Height = 13
        EditLabel.Caption = 'Dst : '
        LabelPosition = lpLeft
        TabOrder = 2
        OnKeyDown = edRedrawOnKeyDown
      end
      object edMatrAttr: TLabeledEdit
        Left = 32
        Top = 3
        Width = 119
        Height = 21
        EditLabel.Width = 27
        EditLabel.Height = 13
        EditLabel.Caption = 'Matr: '
        LabelPosition = lpLeft
        TabOrder = 3
        OnKeyDown = edRedrawOnKeyDown
      end
      object edMatrColor: TEdit
        Left = 156
        Top = 3
        Width = 37
        Height = 21
        TabOrder = 4
        OnClick = EditColor
      end
      object edEnvRectColor: TEdit
        Left = 156
        Top = 27
        Width = 37
        Height = 21
        TabOrder = 5
        OnClick = EditColor
      end
      object edSrcRectColor: TEdit
        Left = 156
        Top = 52
        Width = 37
        Height = 21
        TabOrder = 6
        OnClick = EditColor
      end
      object edDstRectColor: TEdit
        Left = 156
        Top = 78
        Width = 37
        Height = 21
        TabOrder = 7
        OnClick = EditColor
      end
    end
  end
  object ActionList1: TActionList
    Left = 211
    Top = 5
    object aRectsCenterSrcDst: TAction
      Category = 'Rects'
      Caption = 'Center Src, Dst Rects'
      OnExecute = aRectsCenterSrcDstExecute
    end
    object aRectsSameSrcDst: TAction
      Category = 'Rects'
      Caption = 'Same Src, Dst Rects'
      OnExecute = aRectsSameSrcDstExecute
    end
    object aRectsScaleDst: TAction
      Category = 'Rects'
      Caption = 'Scale Dst by Src Rect'
      OnExecute = aRectsScaleDstExecute
    end
  end
  object NLConvPopupMenu: TPopupMenu
    Left = 180
    Top = 5
    object CenterSrcDstRects1: TMenuItem
      Action = aRectsCenterSrcDst
    end
    object SameSrcDstRects1: TMenuItem
      Action = aRectsSameSrcDst
    end
    object ScaleDstbySrcRect1: TMenuItem
      Action = aRectsScaleDst
    end
  end
end

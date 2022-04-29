object N_AffCoefsEditorForm: TN_AffCoefsEditorForm
  Left = 269
  Top = 518
  Width = 260
  Height = 175
  Caption = 'N_AffCoefsEditorForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 252
    Height = 137
    ActivePage = tsOther
    Align = alClient
    TabOrder = 0
    object tsShiftScale: TTabSheet
      Caption = 'Shift/Scale'
      object Label1: TLabel
        Left = 46
        Top = 45
        Width = 20
        Height = 24
        Caption = '+-'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -18
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label2: TLabel
        Left = 178
        Top = 46
        Width = 15
        Height = 24
        Caption = '*/'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -18
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object bnSetFixedPoint: TButton
        Left = 8
        Top = 8
        Width = 33
        Height = 33
        BiDiMode = bdLeftToRight
        Caption = 'SFP'
        ParentBiDiMode = False
        TabOrder = 0
        OnClick = bnSetFixedPointClick
      end
      object bnPS6: TButton
        Tag = 6
        Left = 46
        Top = 5
        Width = 20
        Height = 20
        Caption = '^'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS2: TButton
        Tag = 2
        Left = 46
        Top = 25
        Width = 20
        Height = 20
        Caption = '^'
        TabOrder = 2
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS0: TButton
        Left = 24
        Top = 47
        Width = 20
        Height = 20
        Caption = '<'
        TabOrder = 3
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS4: TButton
        Tag = 4
        Left = 3
        Top = 47
        Width = 20
        Height = 20
        Caption = '<<'
        TabOrder = 4
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS1: TButton
        Tag = 1
        Left = 68
        Top = 47
        Width = 20
        Height = 20
        Caption = '>'
        TabOrder = 5
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS5: TButton
        Tag = 5
        Left = 89
        Top = 47
        Width = 20
        Height = 20
        Caption = '>>'
        TabOrder = 6
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS3: TButton
        Tag = 3
        Left = 46
        Top = 67
        Width = 20
        Height = 20
        Caption = 'v'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 7
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS7: TButton
        Tag = 7
        Left = 46
        Top = 87
        Width = 20
        Height = 20
        Caption = 'W'
        TabOrder = 8
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object cbMantainAspect: TCheckBox
        Left = 73
        Top = 26
        Width = 97
        Height = 17
        Caption = 'Mantain Aspect'
        Checked = True
        State = cbChecked
        TabOrder = 9
      end
      object bnPS22: TButton
        Tag = 22
        Left = 176
        Top = 5
        Width = 20
        Height = 20
        Caption = '^'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 10
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS18: TButton
        Tag = 18
        Left = 176
        Top = 25
        Width = 20
        Height = 20
        Caption = '^'
        TabOrder = 11
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS20: TButton
        Tag = 20
        Left = 133
        Top = 47
        Width = 20
        Height = 20
        Caption = '<<'
        TabOrder = 12
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS16: TButton
        Tag = 16
        Left = 154
        Top = 47
        Width = 20
        Height = 20
        Caption = '<'
        TabOrder = 13
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS17: TButton
        Tag = 17
        Left = 198
        Top = 47
        Width = 20
        Height = 20
        Caption = '>'
        TabOrder = 14
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS21: TButton
        Tag = 21
        Left = 219
        Top = 47
        Width = 20
        Height = 20
        Caption = '>>'
        TabOrder = 15
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS19: TButton
        Tag = 19
        Left = 176
        Top = 68
        Width = 20
        Height = 20
        Caption = 'v'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 16
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS23: TButton
        Tag = 23
        Left = 176
        Top = 88
        Width = 20
        Height = 20
        Caption = 'W'
        TabOrder = 17
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnOK: TButton
        Left = 203
        Top = 77
        Width = 40
        Height = 25
        Caption = 'OK'
        TabOrder = 18
        OnClick = bnOKClick
      end
      object bnCancel: TButton
        Left = 203
        Top = 12
        Width = 40
        Height = 25
        Caption = 'Cancel'
        TabOrder = 19
        OnClick = bnCancelClick
      end
      object edConvAspectCoef: TLabeledEdit
        Left = 120
        Top = 6
        Width = 41
        Height = 21
        EditLabel.Width = 39
        EditLabel.Height = 13
        EditLabel.Caption = 'Aspect :'
        LabelPosition = lpLeft
        TabOrder = 20
      end
      object edFixedPoint: TLabeledEdit
        Left = 69
        Top = 84
        Width = 104
        Height = 21
        EditLabel.Width = 58
        EditLabel.Height = 13
        EditLabel.Caption = 'Fixed Point :'
        TabOrder = 21
      end
    end
    object tsRotate: TTabSheet
      Caption = 'Rotate'
      ImageIndex = 1
      object Label5: TLabel
        Left = 184
        Top = 41
        Width = 14
        Height = 24
        Caption = 'P'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -18
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object bnPS33: TButton
        Tag = 33
        Left = 56
        Top = 30
        Width = 20
        Height = 20
        Caption = '>'
        TabOrder = 0
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS37: TButton
        Tag = 37
        Left = 77
        Top = 30
        Width = 20
        Height = 20
        Caption = '>>'
        TabOrder = 1
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS36: TButton
        Tag = 36
        Left = 8
        Top = 30
        Width = 20
        Height = 20
        Caption = '<<'
        TabOrder = 2
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS32: TButton
        Tag = 32
        Left = 29
        Top = 30
        Width = 20
        Height = 20
        Caption = '<'
        TabOrder = 3
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS54: TButton
        Tag = 54
        Left = 181
        Top = 1
        Width = 20
        Height = 20
        Caption = '^'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS50: TButton
        Tag = 50
        Left = 181
        Top = 21
        Width = 20
        Height = 20
        Caption = '^'
        TabOrder = 5
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS53: TButton
        Tag = 53
        Left = 224
        Top = 43
        Width = 20
        Height = 20
        Caption = '>>'
        TabOrder = 6
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS49: TButton
        Tag = 49
        Left = 203
        Top = 43
        Width = 20
        Height = 20
        Caption = '>'
        TabOrder = 7
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS48: TButton
        Tag = 48
        Left = 159
        Top = 43
        Width = 20
        Height = 20
        Caption = '<'
        TabOrder = 8
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS52: TButton
        Tag = 52
        Left = 138
        Top = 43
        Width = 20
        Height = 20
        Caption = '<<'
        TabOrder = 9
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS51: TButton
        Tag = 51
        Left = 181
        Top = 64
        Width = 20
        Height = 20
        Caption = 'v'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 10
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object bnPS55: TButton
        Tag = 55
        Left = 181
        Top = 83
        Width = 20
        Height = 20
        Caption = 'W'
        TabOrder = 11
        OnMouseDown = bnPS33MouseDown
        OnMouseUp = bnPS33MouseUp
      end
      object edWXY: TLabeledEdit
        Left = 94
        Top = 80
        Width = 82
        Height = 21
        EditLabel.Width = 48
        EditLabel.Height = 13
        EditLabel.Caption = 'WX, WY :'
        TabOrder = 12
        Text = ' 0  0'
        OnKeyDown = edWXYKeyDown
      end
      object edAlfa: TLabeledEdit
        Left = 43
        Top = 3
        Width = 54
        Height = 21
        EditLabel.Width = 37
        EditLabel.Height = 13
        EditLabel.Caption = 'Alfa ('#176') :'
        LabelPosition = lpLeft
        TabOrder = 13
        Text = ' 0 '
        OnKeyDown = edAlfaKeyDown
      end
    end
    object tsOther: TTabSheet
      Caption = 'tsOther 123456789'
      ImageIndex = 2
      object cbStayOnTop: TCheckBox
        Left = 6
        Top = 3
        Width = 97
        Height = 17
        Caption = 'Stay On Top'
        TabOrder = 0
        OnClick = cbStayOnTopClick
      end
    end
  end
  object PSTimer: TTimer
    Interval = 0
    OnTimer = PSTimerTimer
    Left = 208
  end
end

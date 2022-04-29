object N_AlignForm: TN_AlignForm
  Left = 41
  Top = 638
  Width = 267
  Height = 275
  Caption = 'Align Comps'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    259
    237)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 259
    Height = 169
    ActivePage = tsSize
    Align = alTop
    TabOrder = 0
    TabWidth = 36
    object tsPosition: TTabSheet
      Caption = 'Align'
      object cbSolid: TCheckBox
        Left = 125
        Top = 2
        Width = 49
        Height = 17
        Caption = 'Solid'
        TabOrder = 0
      end
      object bnLeft: TButton
        Tag = 1
        Left = 9
        Top = 2
        Width = 54
        Height = 20
        Caption = 'Left'
        TabOrder = 1
        OnClick = AlignButtonsClick
      end
      object bnCenterX: TButton
        Tag = 3
        Left = 9
        Top = 21
        Width = 54
        Height = 20
        Caption = 'Middle X'
        TabOrder = 2
        OnClick = AlignButtonsClick
      end
      object bnRight: TButton
        Tag = 5
        Left = 9
        Top = 40
        Width = 54
        Height = 20
        Caption = 'Right'
        TabOrder = 3
        OnClick = AlignButtonsClick
      end
      object bnTop: TButton
        Tag = 2
        Left = 63
        Top = 2
        Width = 54
        Height = 20
        Caption = 'Top'
        TabOrder = 4
        OnClick = AlignButtonsClick
      end
      object bnMiddleY: TButton
        Tag = 4
        Left = 63
        Top = 21
        Width = 54
        Height = 20
        Caption = 'Middle Y'
        TabOrder = 5
        OnClick = AlignButtonsClick
      end
      object bnBottom: TButton
        Tag = 6
        Left = 63
        Top = 40
        Width = 54
        Height = 20
        Caption = 'Bottom'
        TabOrder = 6
        OnClick = AlignButtonsClick
      end
      object cbFixed: TCheckBox
        Left = 125
        Top = 15
        Width = 49
        Height = 17
        Caption = 'Fixed'
        TabOrder = 7
      end
      object bnEqSpacesX: TButton
        Tag = 11
        Left = 2
        Top = 76
        Width = 82
        Height = 20
        Caption = 'Eq. Spaces X'
        TabOrder = 8
        OnClick = AlignButtonsClick
      end
      object bnUniformX: TButton
        Tag = 13
        Left = 2
        Top = 95
        Width = 82
        Height = 20
        Caption = 'Uniform X'
        TabOrder = 9
        OnClick = AlignButtonsClick
      end
      object bnEqSpacesY: TButton
        Tag = 12
        Left = 91
        Top = 76
        Width = 82
        Height = 20
        Caption = 'Eq. Spaces Y'
        TabOrder = 10
        OnClick = AlignButtonsClick
      end
      object bnUniformY: TButton
        Tag = 14
        Left = 91
        Top = 95
        Width = 82
        Height = 20
        Caption = 'Uniform Y'
        TabOrder = 11
        OnClick = AlignButtonsClick
      end
      object edSpaceCoef: TLabeledEdit
        Left = 66
        Top = 117
        Width = 37
        Height = 21
        EditLabel.Width = 57
        EditLabel.Height = 13
        EditLabel.Caption = 'Space (%) : '
        LabelPosition = lpLeft
        TabOrder = 12
        Text = '99.12'
      end
      object cbIndex: TCheckBox
        Left = 123
        Top = 119
        Width = 49
        Height = 17
        Caption = 'Index'
        TabOrder = 13
      end
    end
    object tsSize: TTabSheet
      Caption = ' Size'
      ImageIndex = 1
      object gbXSize: TGroupBox
        Left = 6
        Top = 4
        Width = 68
        Height = 85
        Caption = ' X Size By '
        TabOrder = 0
        object bnSmallestX: TButton
          Tag = 21
          Left = 5
          Top = 18
          Width = 57
          Height = 20
          Caption = 'Smallest'
          TabOrder = 0
          OnClick = AlignButtonsClick
        end
        object bnLargestX: TButton
          Tag = 23
          Left = 5
          Top = 37
          Width = 57
          Height = 20
          Caption = 'Largest'
          TabOrder = 1
          OnClick = AlignButtonsClick
        end
        object bnFixedX: TButton
          Tag = 25
          Left = 5
          Top = 56
          Width = 57
          Height = 20
          Caption = 'Fixed'
          TabOrder = 2
          OnClick = AlignButtonsClick
        end
      end
      object gbYSize: TGroupBox
        Left = 84
        Top = 4
        Width = 68
        Height = 85
        Caption = ' Y Size By '
        TabOrder = 1
        object bnSmallestY: TButton
          Tag = 22
          Left = 5
          Top = 18
          Width = 57
          Height = 20
          Caption = 'Smallest'
          TabOrder = 0
          OnClick = AlignButtonsClick
        end
        object bnLargestY: TButton
          Tag = 24
          Left = 5
          Top = 34
          Width = 57
          Height = 20
          Caption = 'Largest'
          TabOrder = 1
          OnClick = AlignButtonsClick
        end
        object bnFixedY: TButton
          Tag = 26
          Left = 5
          Top = 53
          Width = 57
          Height = 20
          Caption = 'Fixed'
          TabOrder = 2
          OnClick = AlignButtonsClick
        end
      end
    end
    object tsGrid: TTabSheet
      Caption = 'Grid'
      ImageIndex = 3
      object Label1: TLabel
        Left = 8
        Top = 16
        Width = 62
        Height = 13
        Caption = 'Temporary !!!'
      end
      object rgPositionX: TRadioGroup
        Left = 114
        Top = 9
        Width = 85
        Height = 115
        Caption = ' Position X '
        ItemIndex = 0
        Items.Strings = (
          'No Change'
          'Left'
          'Center'
          'Right'
          'Spaces'
          'Uniform')
        TabOrder = 0
      end
      object rgPositionY: TRadioGroup
        Left = 138
        Top = 89
        Width = 85
        Height = 115
        Caption = ' Position Y '
        ItemIndex = 0
        Items.Strings = (
          'No Change'
          'Top'
          'Center'
          'Bottom'
          'Spaces'
          'Uniform')
        TabOrder = 1
      end
      object rgSizeX: TRadioGroup
        Left = 17
        Top = 48
        Width = 85
        Height = 114
        Caption = ' Size X '
        ItemIndex = 0
        Items.Strings = (
          'No Change'
          'By Smallest'
          'By Largest'
          'Scale (%)')
        TabOrder = 2
      end
      object rgSizeY: TRadioGroup
        Left = 26
        Top = 64
        Width = 85
        Height = 114
        Caption = ' Size Y '
        ItemIndex = 0
        Items.Strings = (
          'No Change'
          'By Smallest'
          'By Largest'
          'Scale (%)')
        TabOrder = 3
      end
      object edScaleXY: TEdit
        Left = 3
        Top = 120
        Width = 36
        Height = 21
        TabOrder = 4
        Text = ' 100'
      end
    end
    object tsEdit: TTabSheet
      Caption = 'Edit'
      ImageIndex = 4
      object rgEdit: TRadioGroup
        Left = 6
        Top = 3
        Width = 89
        Height = 81
        Caption = 'Move/Resize '
        ItemIndex = 0
        Items.Strings = (
          'One Comp'
          'All Comps'
          'Scale Pos')
        TabOrder = 0
      end
    end
    object tsParams: TTabSheet
      Caption = 'Par'
      ImageIndex = 2
      object edUndoLevel: TLabeledEdit
        Left = 93
        Top = 28
        Width = 48
        Height = 21
        EditLabel.Width = 64
        EditLabel.Height = 13
        EditLabel.Caption = 'Undo Level : '
        LabelPosition = lpLeft
        TabOrder = 0
        OnKeyDown = edUndoLevelKeyDown
      end
      object cbStayOnTop: TCheckBox
        Left = 5
        Top = 104
        Width = 97
        Height = 17
        Caption = 'Stay On Top'
        TabOrder = 1
        OnClick = cbStayOnTopClick
      end
    end
  end
  object bnUndo: TButton
    Left = 8
    Top = 215
    Width = 42
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Undo'
    TabOrder = 1
    OnClick = bnUndoClick
  end
  object bnFix: TButton
    Left = 63
    Top = 215
    Width = 42
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Fix'
    TabOrder = 2
    OnClick = bnFixClick
  end
end

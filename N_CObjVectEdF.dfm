object N_CObjVectEditorForm: TN_CObjVectEditorForm
  Left = 376
  Top = 171
  Width = 283
  Height = 314
  Caption = 'N_CObjVectEditorForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 275
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Action = aFileEditComment
    end
    object ToolButton2: TToolButton
      Left = 25
      Top = 2
      Action = aEdCopySavedStrings
    end
  end
  object PageControl: TPageControl
    Left = 0
    Top = 29
    Width = 275
    Height = 208
    ActivePage = tsShape
    Align = alClient
    TabOrder = 1
    OnChange = PageControlChange
    object tsFlags1: TTabSheet
      Caption = 'Flags1'
      object rgSnapMode: TRadioGroup
        Left = 122
        Top = 1
        Width = 122
        Height = 117
        Caption = 'Snap Mode'
        Items.Strings = (
          'Do nothing'
          'Only Highlight'
          'To Beg, Last Vert'
          'To All Vertexes'
          'To Segments only'
          'To Both Segm,Vert')
        TabOrder = 0
        OnClick = rgSnapModeClick
      end
      object rgHighlightSV: TRadioGroup
        Left = 5
        Top = 66
        Width = 109
        Height = 81
        Caption = 'Highlight Segm,Vert'
        Items.Strings = (
          'None'
          'Segments'
          'Vertexes'
          'Both')
        TabOrder = 1
        OnClick = rgHighlightSVClick
      end
      object rgHighlightL: TRadioGroup
        Left = 4
        Top = 0
        Width = 110
        Height = 63
        Caption = 'Highlight Line'
        Items.Strings = (
          'None'
          'Simple Line'
          'Sys Line')
        TabOrder = 2
        OnClick = rgHighlightLClick
      end
    end
    object tsFlags2: TTabSheet
      Caption = 'Flags2'
      ImageIndex = 1
      object rgSplitMode: TRadioGroup
        Left = 3
        Top = 87
        Width = 129
        Height = 68
        Caption = 'Split Mode'
        Items.Strings = (
          'None'
          'Just Add Vertex '
          'Add Vertex and Split')
        TabOrder = 0
        OnClick = rgSplitModeClick
      end
      object rgMoveComVert: TRadioGroup
        Left = 2
        Top = 1
        Width = 130
        Height = 81
        Caption = 'Move Common Vertex'
        Items.Strings = (
          'Move All Segments'
          'Prev Selected'
          'Prev Sel. if Ctrl'
          'Cur. Selected')
        TabOrder = 1
        OnClick = rgMoveComVertClick
      end
    end
    object tsActs1: TTabSheet
      Caption = 'Acts1'
      ImageIndex = 2
      object rbMarkCObj: TRadioButton
        Left = 4
        Top = 86
        Width = 113
        Height = 17
        Caption = 'Mark CObj Part'
        TabOrder = 0
        OnClick = rbMarkCObjClick
      end
      object rbEditItemCode: TRadioButton
        Left = 4
        Top = 137
        Width = 125
        Height = 17
        Caption = 'Edit Item Code'
        TabOrder = 1
        OnClick = rbEditItemCodeClick
      end
      object rbAffConvLine: TRadioButton
        Left = 132
        Top = 121
        Width = 125
        Height = 17
        Caption = 'Aff Conv Line'
        TabOrder = 2
        OnClick = rbAffConvLineClick
      end
      object rbSplitCombLine: TRadioButton
        Left = 132
        Top = 105
        Width = 125
        Height = 17
        Caption = 'Split/Comb Line'
        TabOrder = 3
        OnClick = rbSplitCombLineClick
      end
      object rbDeleteLine: TRadioButton
        Left = 132
        Top = 89
        Width = 125
        Height = 17
        Caption = 'Delete Line'
        TabOrder = 4
        OnClick = rbDeleteLineClick
      end
      object rbNewLine: TRadioButton
        Left = 132
        Top = 73
        Width = 125
        Height = 17
        Caption = 'New    Line'
        TabOrder = 5
        OnClick = rbNewLineClick
      end
      object rbEnlargeLine: TRadioButton
        Left = 132
        Top = 57
        Width = 125
        Height = 17
        Caption = 'Enlarge Line'
        TabOrder = 6
        OnClick = rbEnlargeLineClick
      end
      object rbDeleteVertex: TRadioButton
        Left = 132
        Top = 33
        Width = 125
        Height = 17
        Caption = 'Delete Vertex'
        TabOrder = 7
        OnClick = rbDeleteVertexClick
      end
      object rbAddVertex: TRadioButton
        Left = 132
        Top = 17
        Width = 125
        Height = 17
        Caption = 'Add     Vertex'
        TabOrder = 8
        OnClick = rbAddVertexClick
      end
      object rbMoveVertex: TRadioButton
        Left = 132
        Top = 1
        Width = 125
        Height = 17
        Caption = 'Move  Vertex'
        TabOrder = 9
        OnClick = rbMoveVertexClick
      end
      object rbEmptyAction1: TRadioButton
        Left = 4
        Top = 1
        Width = 125
        Height = 17
        Caption = 'Empty Action'
        Checked = True
        TabOrder = 10
        TabStop = True
        OnClick = rbEmptyAction1Click
      end
      object rbEditRegCodes: TRadioButton
        Left = 4
        Top = 120
        Width = 113
        Height = 17
        Caption = 'Edit RegCodes'
        TabOrder = 11
        OnClick = rbEditRegCodesClick
      end
      object rbSetItemCodes: TRadioButton
        Left = 4
        Top = 103
        Width = 113
        Height = 17
        Caption = 'Set Item Codes'
        TabOrder = 12
        OnClick = rbSetItemCodesClick
      end
    end
    object tsActs2: TTabSheet
      Caption = 'Acts2'
      ImageIndex = 3
      object rbMoveLabel: TRadioButton
        Left = 4
        Top = 79
        Width = 125
        Height = 13
        Caption = 'Move Label'
        TabOrder = 0
        OnClick = rbMoveLabelClick
      end
      object rbEditLabel: TRadioButton
        Left = 4
        Top = 126
        Width = 125
        Height = 13
        Caption = 'Edit    Label'
        TabOrder = 1
        OnClick = rbEditLabelClick
      end
      object rbEmptyAction2: TRadioButton
        Left = 4
        Top = 1
        Width = 125
        Height = 17
        Caption = 'Empty Action'
        Checked = True
        TabOrder = 2
        TabStop = True
        OnClick = rbEmptyAction1Click
      end
      object rbMovePoint: TRadioButton
        Left = 4
        Top = 23
        Width = 125
        Height = 13
        Caption = 'Move Point'
        TabOrder = 3
        OnClick = rbMovePointClick
      end
      object rbAddPoint: TRadioButton
        Left = 4
        Top = 39
        Width = 125
        Height = 13
        Caption = 'Add     Point'
        TabOrder = 4
        OnClick = rbAddPointClick
      end
      object rbDeletePoint: TRadioButton
        Left = 4
        Top = 55
        Width = 125
        Height = 13
        Caption = 'Delete Point'
        TabOrder = 5
        OnClick = rbDeletePointClick
      end
      object rbAddLabel: TRadioButton
        Left = 4
        Top = 93
        Width = 113
        Height = 17
        Caption = 'Add Label'
        TabOrder = 6
        OnClick = rbAddLabelClick
      end
      object rbDeleteLabel: TRadioButton
        Left = 4
        Top = 109
        Width = 113
        Height = 17
        Caption = 'Delete Label'
        TabOrder = 7
        OnClick = rbDeleteLabelClick
      end
    end
    object tsShape: TTabSheet
      Caption = 'Shape'
      ImageIndex = 5
      object ShapePageControl: TPageControl
        Left = 0
        Top = 0
        Width = 267
        Height = 180
        ActivePage = tsOld
        Align = alClient
        TabOrder = 0
        object tsOld: TTabSheet
          Caption = 'tsOld'
          ImageIndex = 1
          object rgShapeType: TRadioGroup
            Left = 0
            Top = 6
            Width = 72
            Height = 104
            Caption = 'Shape Type'
            ItemIndex = 0
            Items.Strings = (
              'Circle'
              'Polygon'
              'Ring')
            TabOrder = 0
          end
          object edShapeR2: TLabeledEdit
            Left = 193
            Top = 56
            Width = 54
            Height = 21
            EditLabel.Width = 20
            EditLabel.Height = 13
            EditLabel.Caption = 'R2 :'
            LabelPosition = lpLeft
            TabOrder = 1
            Text = ' 0.5'
            OnDblClick = edShapeR2DblClick
          end
          object edShapeR1: TLabeledEdit
            Left = 108
            Top = 56
            Width = 54
            Height = 21
            EditLabel.Width = 20
            EditLabel.Height = 13
            EditLabel.Caption = 'R1 :'
            LabelPosition = lpLeft
            TabOrder = 2
            Text = ' 1.5'
            OnDblClick = edShapeR1DblClick
          end
          object edShapeNumVerts: TLabeledEdit
            Left = 135
            Top = 30
            Width = 31
            Height = 21
            EditLabel.Width = 55
            EditLabel.Height = 13
            EditLabel.Caption = 'Num Verts :'
            LabelPosition = lpLeft
            TabOrder = 3
            Text = ' 3'
          end
          object edShapeCenter: TLabeledEdit
            Left = 125
            Top = 5
            Width = 109
            Height = 21
            EditLabel.Width = 37
            EditLabel.Height = 13
            EditLabel.Caption = 'Center :'
            LabelPosition = lpLeft
            TabOrder = 4
            Text = ' 0  0'
            OnDblClick = edShapeCenterDblClick
          end
          object edShapeAngle: TLabeledEdit
            Left = 210
            Top = 30
            Width = 36
            Height = 21
            EditLabel.Width = 33
            EditLabel.Height = 13
            EditLabel.Caption = 'Angle :'
            LabelPosition = lpLeft
            TabOrder = 5
            Text = ' 0'
          end
          object bnCreateShape: TButton
            Left = 171
            Top = 93
            Width = 75
            Height = 25
            Action = aOtherCreateShape
            TabOrder = 6
          end
        end
        object tsRoundRect: TTabSheet
          Caption = 'Round Rect'
          object edRRUpperLeft: TLabeledEdit
            Left = 67
            Top = 5
            Width = 76
            Height = 21
            EditLabel.Width = 56
            EditLabel.Height = 13
            EditLabel.Caption = 'Upper Left :'
            LabelPosition = lpLeft
            TabOrder = 0
          end
          object edRadiusX: TLabeledEdit
            Left = 216
            Top = 5
            Width = 33
            Height = 21
            EditLabel.Width = 49
            EditLabel.Height = 13
            EditLabel.Caption = 'Radius X :'
            LabelPosition = lpLeft
            TabOrder = 1
            Text = ' 0'
          end
          object edRRLowerRight: TLabeledEdit
            Left = 67
            Top = 36
            Width = 77
            Height = 21
            EditLabel.Width = 63
            EditLabel.Height = 13
            EditLabel.Caption = 'Lower Right :'
            LabelPosition = lpLeft
            TabOrder = 2
            Text = ' 30 30'
          end
          object edRadiusY: TLabeledEdit
            Left = 216
            Top = 36
            Width = 33
            Height = 21
            EditLabel.Width = 49
            EditLabel.Height = 13
            EditLabel.Caption = 'Radius Y :'
            LabelPosition = lpLeft
            TabOrder = 3
          end
          object edRRNumSegments: TLabeledEdit
            Left = 216
            Top = 68
            Width = 33
            Height = 21
            EditLabel.Width = 78
            EditLabel.Height = 13
            EditLabel.Caption = 'Num Segments :'
            LabelPosition = lpLeft
            TabOrder = 4
            Text = ' 0'
          end
          object bnCreateRR: TButton
            Left = 28
            Top = 95
            Width = 204
            Height = 25
            Caption = 'Create Round Rect'
            TabOrder = 5
            OnClick = bnCreateRRClick
          end
        end
        object tsRegPolyFragm: TTabSheet
          Caption = 'RP Fragm'
          ImageIndex = 2
          object bnCreateRPFragm: TButton
            Left = 28
            Top = 95
            Width = 204
            Height = 25
            Caption = 'Create Regular Polygon Fragment (s)'
            TabOrder = 0
            OnClick = bnCreateRPFragmClick
          end
          object edRPFUpperLeft: TLabeledEdit
            Left = 67
            Top = 5
            Width = 76
            Height = 21
            EditLabel.Width = 56
            EditLabel.Height = 13
            EditLabel.Caption = 'Upper Left :'
            LabelPosition = lpLeft
            TabOrder = 1
          end
          object edRPFLowerRight: TLabeledEdit
            Left = 67
            Top = 36
            Width = 77
            Height = 21
            EditLabel.Width = 63
            EditLabel.Height = 13
            EditLabel.Caption = 'Lower Right :'
            LabelPosition = lpLeft
            TabOrder = 2
          end
          object edScaleCoef: TLabeledEdit
            Left = 68
            Top = 68
            Width = 35
            Height = 21
            EditLabel.Width = 58
            EditLabel.Height = 13
            EditLabel.Caption = 'Scale Coef :'
            LabelPosition = lpLeft
            TabOrder = 3
            Text = '1.0'
          end
          object edAngleBeg: TLabeledEdit
            Left = 216
            Top = 5
            Width = 33
            Height = 21
            EditLabel.Width = 55
            EditLabel.Height = 13
            EditLabel.Caption = 'Angle Beg :'
            LabelPosition = lpLeft
            TabOrder = 4
            Text = '0'
          end
          object edAngleSize: TLabeledEdit
            Left = 216
            Top = 36
            Width = 33
            Height = 21
            EditLabel.Width = 56
            EditLabel.Height = 13
            EditLabel.Caption = 'Angle Size :'
            LabelPosition = lpLeft
            TabOrder = 5
            Text = '0'
          end
          object edRPFNumSegments: TLabeledEdit
            Left = 216
            Top = 68
            Width = 33
            Height = 21
            EditLabel.Width = 78
            EditLabel.Height = 13
            EditLabel.Caption = 'Num Segments :'
            LabelPosition = lpLeft
            TabOrder = 6
          end
        end
      end
    end
    object tsOther: TTabSheet
      Caption = 'Other'
      ImageIndex = 4
      object PageControl1: TPageControl
        Left = 0
        Top = 0
        Width = 267
        Height = 180
        ActivePage = tsGeneral
        Align = alClient
        TabOrder = 0
        object tsGeneral: TTabSheet
          Caption = 'General'
          DesignSize = (
            259
            152)
          object Label1: TLabel
            Left = 9
            Top = 0
            Width = 53
            Height = 13
            Caption = 'Aux Layer :'
          end
          object edEdGFlags: TLabeledEdit
            Left = 16
            Top = 53
            Width = 97
            Height = 21
            EditLabel.Width = 79
            EditLabel.Height = 13
            EditLabel.Caption = 'Ed Group Flags :'
            TabOrder = 0
          end
          object cbMultiSelect: TCheckBox
            Left = 16
            Top = 79
            Width = 81
            Height = 17
            Caption = 'MultiSelect'
            TabOrder = 1
            OnClick = cbMultiSelectClick
          end
          object edRedrawLLWPixSize: TLabeledEdit
            Left = 216
            Top = 79
            Width = 26
            Height = 21
            EditLabel.Width = 29
            EditLabel.Height = 13
            EditLabel.Caption = 'LLW :'
            LabelPosition = lpLeft
            TabOrder = 2
            OnKeyDown = edRedrawLLWPixSizeKeyDown
          end
          object edSearchSize: TLabeledEdit
            Left = 215
            Top = 107
            Width = 28
            Height = 21
            EditLabel.Width = 60
            EditLabel.Height = 13
            EditLabel.Caption = 'Search Size:'
            LabelPosition = lpLeft
            TabOrder = 3
            Text = 'no!'
          end
          object cbStayOnTop: TCheckBox
            Left = 161
            Top = 136
            Width = 89
            Height = 17
            Caption = 'Stay On Top'
            TabOrder = 4
            OnClick = cbStayOnTopClick
          end
          inline frAuxCL: TN_UObj2Frame
            Left = 2
            Top = 16
            Width = 252
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 5
            inherited mb: TComboBox
              Width = 250
            end
          end
          object edCDimInd: TLabeledEdit
            Left = 216
            Top = 51
            Width = 26
            Height = 21
            EditLabel.Width = 46
            EditLabel.Height = 13
            EditLabel.Caption = 'CDimInd :'
            LabelPosition = lpLeft
            TabOrder = 6
            Text = ' 0'
            OnKeyDown = edCDimIndKeyDown
          end
          inline PixMesFrame: TN_PixMesFrame
            Left = 16
            Top = 125
            Width = 49
            Height = 25
            TabOrder = 7
            inherited edCurColor: TEdit
              Width = 49
            end
          end
        end
        object tsStats: TTabSheet
          Caption = 'Stats'
          ImageIndex = 1
          object edOSMinSize: TLabeledEdit
            Left = 38
            Top = 5
            Width = 68
            Height = 21
            EditLabel.Width = 26
            EditLabel.Height = 13
            EditLabel.Caption = 'Min : '
            LabelPosition = lpLeft
            TabOrder = 0
            OnKeyDown = edRedrawLLWPixSizeKeyDown
          end
          object edOSMaxSize: TLabeledEdit
            Left = 39
            Top = 32
            Width = 67
            Height = 21
            EditLabel.Width = 29
            EditLabel.Height = 13
            EditLabel.Caption = 'Max : '
            LabelPosition = lpLeft
            TabOrder = 1
            OnKeyDown = edRedrawLLWPixSizeKeyDown
          end
          object edOSNumGroups: TLabeledEdit
            Left = 74
            Top = 59
            Width = 32
            Height = 21
            EditLabel.Width = 68
            EditLabel.Height = 13
            EditLabel.Caption = 'Num Groups : '
            LabelPosition = lpLeft
            TabOrder = 2
            OnKeyDown = edRedrawLLWPixSizeKeyDown
          end
        end
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 237
    Width = 275
    Height = 19
    Panels = <>
  end
  object MainMenu1: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 168
    object File1: TMenuItem
      Caption = 'File'
      object EditCObjComment1: TMenuItem
        Action = aFileEditComment
      end
    end
    object Notyet1: TMenuItem
      Caption = 'Edit'
      object CopySavedStrings1: TMenuItem
        Action = aEdCopySavedStrings
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object AffConvMarked1: TMenuItem
        Action = aEdAffConvMarked
      end
      object AffConvLayer1: TMenuItem
        Action = aEdAffConvLayer
      end
      object SetRegionCodesToMarked1: TMenuItem
        Action = aEdSetRCToMarked
      end
      object SetRegionCodesToLayer1: TMenuItem
        Action = aEdSetRCToLayer
      end
      object CopyMarked1: TMenuItem
        Action = aEdCopyMarked
      end
      object MoveMarked1: TMenuItem
        Action = aEdMoveMarked
      end
      object UnSparseLayer1: TMenuItem
        Action = aEdUnSparseLayer
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object DeleteMarkedItemsParts1: TMenuItem
        Action = aEdDeleteMarked
      end
      object ClearAllItems1: TMenuItem
        Action = aEdDeleteAll
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object ViewSegments1: TMenuItem
        Action = aViewSegments
      end
    end
    object Other1: TMenuItem
      Caption = 'Other'
      object CreateShape1: TMenuItem
        Action = aOtherCreateShape
      end
    end
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 200
    object aEdSplitItem: TAction
      Category = 'Edit'
      Caption = 'Split Item'
      OnExecute = aEdSplitItemExecute
    end
    object aEdCombineParts: TAction
      Category = 'Edit'
      Caption = 'Combine Parts'
      OnExecute = aEdCombinePartsExecute
    end
    object aEdAffConvMarked: TAction
      Category = 'Edit'
      Caption = 'Aff. Conv. Marked'
      OnExecute = aEdAffConvMarkedExecute
    end
    object aEdAffConvLayer: TAction
      Category = 'Edit'
      Caption = 'Aff. Conv. Layer'
      OnExecute = aEdAffConvLayerExecute
    end
    object aEdSetRCToMarked: TAction
      Category = 'Edit'
      Caption = 'Set Region Codes To Marked'
      OnExecute = aEdSetRCToMarkedExecute
    end
    object aEdSetRCToLayer: TAction
      Category = 'Edit'
      Caption = 'Set Region Codes To Layer'
      OnExecute = aEdSetRCToLayerExecute
    end
    object aOtherCreateShape: TAction
      Category = 'Other'
      Caption = 'Create Shape'
      OnExecute = aOtherCreateShapeExecute
    end
    object aEdCopyMarked: TAction
      Category = 'Edit'
      Caption = 'Copy Marked'
      OnExecute = aEdCopyMarkedExecute
    end
    object aEdMoveMarked: TAction
      Category = 'Edit'
      Caption = 'Move Marked'
      OnExecute = aEdMoveMarkedExecute
    end
    object aEdUnSparseLayer: TAction
      Category = 'Edit'
      Caption = 'UnSparse Layer'
      OnExecute = aEdUnSparseLayerExecute
    end
    object aEdDeleteAll: TAction
      Category = 'Edit'
      Caption = 'Delete All Items'
      OnExecute = aEdDeleteAllExecute
    end
    object aEdDeleteMarked: TAction
      Category = 'Edit'
      Caption = 'Delete Marked Items (Parts)'
      OnExecute = aEdDeleteMarkedExecute
    end
    object aFileEditComment: TAction
      Category = 'File'
      Caption = 'Edit CObj Comment'
      ImageIndex = 31
      OnExecute = aFileEditCommentExecute
    end
    object aViewSegments: TAction
      Category = 'View'
      Caption = 'View Segments'
      OnExecute = aViewSegmentsExecute
    end
    object aEdCopySavedStrings: TAction
      Category = 'Edit'
      Caption = 'Copy Saved Strings'
      ImageIndex = 12
      OnExecute = aEdCopySavedStringsExecute
    end
  end
end

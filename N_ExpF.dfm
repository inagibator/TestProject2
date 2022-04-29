object N_ExportForm: TN_ExportForm
  Left = 386
  Top = 755
  Width = 465
  Height = 383
  Caption = 'Export Objects from Archive'
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
  object Label10: TLabel
    Left = 15
    Top = 31
    Width = 80
    Height = 13
    Caption = 'CObjects Name :'
  end
  object Label11: TLabel
    Left = 161
    Top = 31
    Width = 74
    Height = 13
    Caption = 'CObjects Path :'
  end
  inline frMain: TN_FileNameFrame
    Tag = 161
    Left = 5
    Top = 79
    Width = 394
    Height = 32
    PopupMenu = frMain.FilePopupMenu
    TabOrder = 0
    inherited Label1: TLabel
      Left = 3
      Width = 48
      Caption = 'Main File :'
    end
    inherited mbFileName: TComboBox
      Left = 57
      Width = 288
      OnChange = nil
    end
    inherited bnBrowse_1: TButton
      Left = 347
      Caption = '````'
    end
  end
  inline frAux: TN_FileNameFrame
    Tag = 161
    Left = 6
    Top = 106
    Width = 393
    Height = 32
    PopupMenu = frAux.FilePopupMenu
    TabOrder = 1
    inherited Label1: TLabel
      Left = 8
      Width = 43
      Caption = 'Aux File :'
    end
    inherited mbFileName: TComboBox
      Left = 56
      Width = 289
    end
    inherited bnBrowse_1: TButton
      Left = 346
    end
  end
  object PageControl: TPageControl
    Left = 8
    Top = 140
    Width = 393
    Height = 144
    ActivePage = tsOther
    TabOrder = 2
    object tsShape: TTabSheet
      Caption = 'Shape'
      object bnConvertShapeToASCII: TButton
        Left = 6
        Top = 4
        Width = 131
        Height = 25
        Caption = 'Convert Shape To ASCII'
        TabOrder = 0
      end
    end
    object tsTDB: TTabSheet
      Caption = 'TDB'
      ImageIndex = 1
      object Label2: TLabel
        Left = 9
        Top = 5
        Width = 89
        Height = 13
        Caption = 'TDB Table Name :'
      end
      object Label5: TLabel
        Left = 136
        Top = 8
        Width = 94
        Height = 13
        Caption = 'Data Vector Name :'
      end
      object mbTDBTableName: TComboBox
        Left = 11
        Top = 20
        Width = 105
        Height = 21
        ItemHeight = 13
        ItemIndex = 1
        TabOrder = 0
        Text = 'lines'
        Items.Strings = (
          'points'
          'lines'
          'contours')
      end
      object mbDataVectorName: TComboBox
        Left = 132
        Top = 20
        Width = 129
        Height = 21
        ItemHeight = 13
        TabOrder = 1
        Items.Strings = (
          'FillColors'
          'LineColors')
      end
    end
    object tsKRLB: TTabSheet
      Caption = 'KRLB'
      ImageIndex = 4
    end
    object tsHTML: TTabSheet
      Caption = 'HTML'
      ImageIndex = 3
      inline frExpFN1: TN_FileNameFrame
        Tag = 161
        Left = 9
        Top = 5
        Width = 368
        Height = 32
        PopupMenu = frExpFN1.FilePopupMenu
        TabOrder = 0
        inherited Label1: TLabel
          Left = 0
          Width = 59
          Caption = 'File Name 1:'
        end
        inherited mbFileName: TComboBox
          Width = 252
        end
        inherited bnBrowse_1: TButton
          Left = 321
        end
      end
      inline frExpFN2: TN_FileNameFrame
        Tag = 161
        Left = 9
        Top = 33
        Width = 368
        Height = 32
        PopupMenu = frExpFN2.FilePopupMenu
        TabOrder = 1
        inherited Label1: TLabel
          Left = 0
          Width = 59
          Caption = 'File Name 2:'
        end
        inherited mbFileName: TComboBox
          Width = 252
        end
        inherited bnBrowse_1: TButton
          Left = 321
        end
      end
      inline frExpFN3: TN_FileNameFrame
        Tag = 161
        Left = 9
        Top = 63
        Width = 368
        Height = 32
        PopupMenu = frExpFN3.FilePopupMenu
        TabOrder = 2
        inherited Label1: TLabel
          Left = 0
          Width = 59
          Caption = 'File Name 3:'
        end
        inherited mbFileName: TComboBox
          Width = 252
        end
        inherited bnBrowse_1: TButton
          Left = 321
        end
      end
    end
    object tsSVG: TTabSheet
      Caption = 'SVG'
      ImageIndex = 4
      object Label3: TLabel
        Left = 10
        Top = 72
        Width = 51
        Height = 13
        Caption = 'Encoding :'
      end
      object Label4: TLabel
        Left = 106
        Top = 8
        Width = 51
        Height = 13
        Caption = 'Accuracy :'
      end
      object Label6: TLabel
        Left = 123
        Top = 34
        Width = 34
        Height = 13
        Caption = 'Width :'
      end
      object rgFileType: TRadioGroup
        Left = 8
        Top = 8
        Width = 89
        Height = 57
        Caption = ' File Type : '
        ItemIndex = 0
        Items.Strings = (
          'JS in HTML'
          'JS in SVG')
        TabOrder = 0
      end
      object mbEncoding: TComboBox
        Left = 8
        Top = 88
        Width = 89
        Height = 21
        ItemHeight = 13
        TabOrder = 1
        Text = 'utf-8'
        Items.Strings = (
          'iso-8859-1'
          'utf-8')
      end
      object edAccuracy: TEdit
        Left = 162
        Top = 5
        Width = 32
        Height = 21
        TabOrder = 2
        Text = 'edAccuracy'
      end
      object edWidth: TEdit
        Left = 162
        Top = 31
        Width = 33
        Height = 21
        TabOrder = 3
        Text = '8002'
      end
    end
    object tsOther: TTabSheet
      Caption = 'Other'
      ImageIndex = 5
      object lMapUObj: TLabel
        Left = 5
        Top = 9
        Width = 54
        Height = 13
        Caption = 'Map UObj :'
      end
      inline frMapUObj: TN_UObjFrame
        Left = 62
        Top = 4
        Width = 228
        Height = 25
        TabOrder = 0
        inherited mb: TComboBox
          Left = 0
          Width = 187
        end
        inherited bnBrowse: TButton
          Left = 195
        end
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 318
    Width = 457
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 457
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Caption = 'ToolButton1'
    end
    object ToolButton2: TToolButton
      Left = 25
      Top = 2
      Caption = 'ToolButton2'
    end
  end
  inline frCObjName: TN_UObjFrame
    Left = 1
    Top = 48
    Width = 149
    Height = 25
    TabOrder = 5
    inherited mb: TComboBox
      Left = 1
      Width = 122
    end
    inherited bnBrowse: TButton
      Left = 124
    end
  end
  inline frCObjPath: TN_UObjFrame
    Left = 150
    Top = 48
    Width = 228
    Height = 25
    TabOrder = 6
    inherited mb: TComboBox
      Left = 5
      Width = 195
    end
    inherited bnBrowse: TButton
      Left = 203
    end
  end
  object MainMenu1: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 347
    Top = 65535
    object mmShape: TMenuItem
      Caption = 'Shape'
      object ShapeToASCII1: TMenuItem
        Action = actExpShpPoints
      end
      object ExportLines2: TMenuItem
        Action = actExpShpLines
      end
      object ExportPolygons1: TMenuItem
        Action = actExpShpPolygons
      end
    end
    object mmTDB: TMenuItem
      Caption = 'TDB'
    end
    object mmKRLB: TMenuItem
      Caption = 'KRLB'
      object ExportLines1: TMenuItem
        Action = actExpKrlbLines
      end
    end
    object mmHTML: TMenuItem
      Caption = 'HTML'
      object oHTMLMap1: TMenuItem
        Action = actToHTMLMap
      end
    end
    object mmSVG: TMenuItem
      Caption = 'SVG'
      object ExportMaptoSVG1: TMenuItem
        Action = aSVGExportMap
      end
      object ExportLayertoSVG1: TMenuItem
        Action = aSVGExportLayer
      end
      object aSVGExportMapToJavaScript1: TMenuItem
        Action = aSVGExportMapToJS
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object ExportVCTreetoSVG1: TMenuItem
        Action = aSVGExportVCTree
      end
      object ExportVCTreeToText1: TMenuItem
        Action = aSVGExportToText
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object SVGTest11: TMenuItem
        Action = aSVGTest1
      end
      object SVGTest21: TMenuItem
        Action = aSVGTest2
      end
    end
    object Data1: TMenuItem
      Caption = 'Data'
    end
    object mmTools: TMenuItem
      Caption = 'Tools'
      object ViewMainFile1: TMenuItem
        Action = aViewMainFile
      end
      object ViewAuxFile1: TMenuItem
        Action = aViewAuxFile
      end
    end
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 376
    Top = 65535
    object actToHTMLMap: TAction
      Category = 'HTML'
      Caption = 'To HTML Map'
      OnExecute = actToHTMLMapExecute
    end
    object actExpKrlbLines: TAction
      Category = 'KRLB'
      Caption = 'Export Cont. Borders'
      OnExecute = actExpKrlbLinesExecute
    end
    object actExpShpPoints: TAction
      Category = 'Shape'
      Caption = 'Export Points'
      OnExecute = actExpShpPointsExecute
    end
    object actExpShpLines: TAction
      Category = 'Shape'
      Caption = 'Export  Lines'
      OnExecute = actExpShpLinesExecute
    end
    object actExpShpPolygons: TAction
      Category = 'Shape'
      Caption = 'Export Polygons'
      OnExecute = actExpShpPolygonsExecute
    end
    object aSVGExportMap: TAction
      Category = 'SVG'
      Caption = 'Export Map to SVG'
      OnExecute = aSVGExportMapExecute
    end
    object aSVGExportLayer: TAction
      Category = 'SVG'
      Caption = 'Export Layer to SVG'
      OnExecute = aSVGExportLayerExecute
    end
    object aSVGExportMapToJS: TAction
      Category = 'SVG'
      Caption = 'Export Map To JavaScript'
      OnExecute = aSVGExportMapToJSExecute
    end
    object aSVGTest1: TAction
      Category = 'SVG'
      Caption = 'SVG Test1'
      OnExecute = aSVGTest1Execute
    end
    object aSVGTest2: TAction
      Category = 'SVG'
      Caption = 'SVG Test2'
      OnExecute = aSVGTest2Execute
    end
    object aViewMainFile: TAction
      Category = 'Tools'
      Caption = 'View Main File'
      OnExecute = aViewMainFileExecute
    end
    object aViewAuxFile: TAction
      Category = 'Tools'
      Caption = 'View Aux File'
      OnExecute = aViewAuxFileExecute
    end
    object aSVGExportVCTree: TAction
      Category = 'SVG'
      Caption = 'Export VCTree to SVG'
      OnExecute = aSVGExportVCTreeExecute
    end
    object aSVGExportToText: TAction
      Category = 'SVG'
      Caption = 'Export VCTree To Text'
      OnExecute = aSVGExportToTextExecute
    end
  end
end

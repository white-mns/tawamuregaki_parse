#===================================================================
#        戦闘結果解析パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;


require "./source/lib/IO.pm";
require "./source/lib/time.pm";
require "./source/lib/NumCode.pm";

require "./source/chara/Name.pm";
require "./source/battle/Page.pm";
require "./source/battle/Party.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package Battle;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;

  bless {
    Datas         => {},
    DataHandlers  => {},
    Methods       => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init() {
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;

    #インスタンス作成
    if (ConstData::EXE_BATTLE_CHARANAME) { $self->{DataHandlers}{Name}  = Name->new();}
    if (ConstData::EXE_BATTLE_PAGE)      { $self->{DataHandlers}{Page}  = Page->new();}
    if (ConstData::EXE_BATTLE_PARTY)     { $self->{DataHandlers}{Party} = Party->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});
    }
    
    return;
}

#-----------------------------------#
#    圧縮結果から戦闘結果ファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;

    print "read character files...\n";

    my $start = 1;
    my $end   = 0;
    my $directory = './data/utf/result' . $self->{ResultNo} . '/';
    
    if (ConstData::EXE_ALLRESULT) {
        #結果全解析
        $end = GetMaxFileNo($directory,"");
    }else{
        #指定範囲解析
        $start = ConstData::FLAGMENT_START;
        $end   = ConstData::FLAGMENT_END;
    }

    print "$start to $end\n";

    for (my $e_no=$start; $e_no<=$end; $e_no++) {
        if ($e_no % 10 == 0) {print $e_no . "\n"};

        $self->ParsePage($directory."/".$e_no.".html",$e_no);
    }
    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
##-----------------------------------#
sub ParsePage{
    my $self        = shift;
    my $file_name   = shift;
    my $battle_no        = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::FileRead($file_name);

    if (!$content) { return;}

    $content = &NumCode::EncodeEscape($content);
        
    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $title_b_nodes = &GetNode::GetNode_Tag_Attr("b", "class", "T6", \$tree);
    my $turn_table_nodes = &GetNode::GetNode_Tag_Attr("table", "width", "700", \$tree);

    # データリスト取得
    if (exists($self->{DataHandlers}{Name}))  {$self->{DataHandlers}{Name}->GetData ($battle_no, $turn_table_nodes)};
    if (exists($self->{DataHandlers}{Page}))  {$self->{DataHandlers}{Page}->GetData ($battle_no, $turn_table_nodes, $$title_b_nodes[0])};
    if (exists($self->{DataHandlers}{Party})) {$self->{DataHandlers}{Party}->GetData($battle_no, $turn_table_nodes)};

    $tree = $tree->delete;
}

#-----------------------------------#
#       該当ファイル数を取得
#-----------------------------------#
#    引数｜ディレクトリ名
#    　　　ファイル接頭辞
##-----------------------------------#
sub GetMaxFileNo{
    my $directory   = shift;
    my $prefix    = shift;

    #ファイル名リストを取得
    my @fileList = grep { -f } glob("$directory/$prefix*.html");

    my $max= 0;
    foreach (@fileList) {
        $_ =~ /$prefix(\d+).html/;
        if ($max < $1) {$max = $1;}
    }
    return $max
}

#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Output();
    }
    return;
}

1;

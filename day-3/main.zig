const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const start = std.time.microTimestamp();

    print("Total Part 1: {}\n", .{Solver.solvePart1()});
    print("Total Part 2: {}\n", .{Solver.solvePart2()});

    const end = std.time.microTimestamp();
    const micros = end - start;
    const millis = @as(f32, @floatFromInt(micros)) / 1000;
    print("\nExecution time: {d:.3}ms\n", .{millis});
}

const Solver = struct {
    i: usize,
    total: u32,
    enabled: u1,

    fn init() Solver {
        return .{ .i = 0, .total = 0, .enabled = 1 };
    }

    const MUL = "mul(";
    const DO = "do()";
    const DONT = "don't()";

    fn solvePart1() u32 {
        var self = Solver.init();
        while (self.i < input.len - MUL.len) {
            self.scanMul();
        }
        return self.total;
    }

    fn solvePart2() u32 {
        var self = Solver.init();
        while (self.i < input.len - MUL.len) {
            switch (self.enabled) {
                1 => self.scanMul(),
                0 => self.scanDo(),
            }
        }
        return self.total;
    }

    fn scanDo(self: *Solver) void {
        if (self.nextEqlTo(DO)) {
            self.enabled = 1;
            self.i += DO.len;
            return;
        }
        self.i += 1;
    }

    fn scanMul(self: *Solver) void {
        if (self.nextEqlTo(MUL)) {
            self.i += MUL.len;
            self.parseMul();
            return;
        }
        if (self.nextEqlTo(DONT)) {
            self.enabled = 0;
            self.i += DONT.len;
            return;
        }
        self.i += 1;
    }

    fn nextEqlTo(self: *Solver, other: []const u8) bool {
        const s = input[self.i .. self.i + other.len];
        return std.mem.eql(u8, s, other);
    }

    fn parseMul(self: *Solver) void {
        const l = self.parseInt();
        if (self.readChar() != ',') {
            return;
        }
        const r = self.parseInt();
        if (self.readChar() != ')') {
            return;
        }
        self.total += l * r;
    }

    fn parseInt(self: *Solver) u32 {
        var n: u32 = 0;
        while (true) {
            const d = input[self.i];
            if (d < '0' or d > '9') {
                break;
            }
            n = n * 10 + d - 48;
            self.i += 1;
        }
        return n;
    }

    fn readChar(self: *Solver) u8 {
        const c = input[self.i];
        self.i += 1;
        return c;
    }
};

const input =
    \\~-mul(858,892)?@#mul(380,985)what()[^what()%mul(340,11)~*}don't())/~-mul(849,387)%-why()when():how()>-,what()mul(605,504)what()~:]what();how()who()];mul(771,783)?^ who()}~?>mul(111,830))@ ~mul(329,797)%'why()why()mul(125,409)-*/where()()@&!why()mul(390,37)when(974,538)#/when()){/don't()/mul(20,990)}?%{(who()mul(627,567)(how()'<(#%how()mul(387,315){;%who()%#from()mul(868,680)}^$mul(862,19)mul(847,689)>((#@when()}mul(339,156)+/{}@{^%[why(231,704)mul(236,754)]'^where(978,690)mul(460,872)#'*mul(518,944)>mul(301,886))mul(477,933)^mul(685,909)who())]what(288,791)mul(170,434){ &where()~(@where()mul(191,104)mul(637,600)&select()why())~select()mul(534,617)?mul(763,508){from()when(22,266)+who() when()mul(204,352)when()mul(426,122)-<*where()'$ why()mul(192,980)[(#[!$-}mul(798,208)''[!where()what()select()mul(295,727))#)}($<?<mul(452,502)(don't()mul(737,492)>,$%where(539,126)what()when()select()'@mul(311,541),?don't()#select()!}!(}&?mul(100,142)),-}%mul(222,856)~$;>!from()where()mul(758,901)mul(757,796)mul(976,686);@'~+-{#who()mul(26,971);mul(404,362)^~who(417,106)what()#mul(186,691)from() %#+{/mul(67,433)-who()!-+!mul(184,469)*when()[&when(458,221)<$mul(163,556)^)]?,'}&+who()mul(514,239)~)(mul(143,441)'how(741,776)~who(766,575)when();>*^mul(281,143)+!>;+:mul(767,44)#<mul(490,849)> when()why()don't()how()from()[from()from(){mul(436,519)what() *who();@{,>do()%'mul(19,540)when()mul(643,539)~when(812,543)mul(527,639)-!mul(409,379)where()/(mul(168,491)#$>]mul(432,333)@%<when();{?what()^mul(819,413)'where(65,845)}-' ^@don't()?how()when()>><mul(591,832)where(600,755)]who()}do()!^-$what()from()select()'#mul(572,956)@#:what()from(),]mul(303,346) when()$$how()@%/#$mul(857,344)/what()where()mul(969,234)$!#when()>>&who()(mul(113,494)%where()why()when()mul(659,592)<why()!<}mul(429,162)[who()*>#(/'mul(72,670)when()^^mul(369,596)mul(631,168)-why()()[*}mul(330,968) $why()where()mul(230,139)don't()@)@<mul(849,413)-when(){*?]mul(821,9)mul(753,277)]{&when()%:mul(262,360)what()mul(65,276)don't()])who();where()$!,(-mul(952,221)+:/{where()where()mul(608,843)'>where())%}where()&,}mul(875,661)~don't()':why(){mul(793*:mul(399,702)!://select()@when()why()do()@mul(488,581{?{&<who(617,140)@how()mul(156,982)why()'&<where()*:{mul(452{-+$$*/mul(202,724)]#:#why()+??(#mul(607,2)@^mul(20,845)#{+#[/#~/mul(111,872)how()select()]<how())'how()mul(921,254)$:;/where() ~why()}?mul(558,122)@how()<<who()mul(992,319)what(734,450)[^mul(498,490)/mul(632,639)when()]from(){why()]$[who(664,268)mul(401,695]!>how()&select()!<'mul(912,311)why()! })@+}mul(128*mul(626,752)%mul(49,60)[,who()what()select()<what()mul(24,8)>)@@]*]why(937,788)from():mul(945,658)<]don't()where()how(515,644)@+'select()how()mul(369,665)/],<when(){( $how()mul(361,594)$select()&:{:$when()mul(52,806) #from()@when()where():>mul(263,185)where()^why()why()@what()mul(82,407)mul(464,537)[mul(871,333)^mul(560,227)-why()mul(966,203)$what()+where()#mul(101,21)}%how(),)^who()>,select()mul(667,565)('what(),%select()(@mul(500,204:''<~'why(477,559)<do()>)[where()mul(698,648);how(){&?what()^@[%mul(280,395)>~, mul-#/%:where()>where():mul(170,746)don't()}($:@mul(998,876)*~<[mul(121,366)-?#;how()>from() ::mul(804,883)^-[  (:mul(100,354who(544,766)+,]>!['/;mul(949,115)
    \\[^!})from()&mul(617,518)*how()(:@who()what()/mul(591,163):what()?{'do()!/when()!$mul(394,797)]how(620,741)!:!mul&%mul(523,862) ~}where()why()}from()! @do()mul(270,205)from()[&^mul(577,474)?{*/why()*what()mul(656,30)where()+#,@mul(295,616)why()/mul(8,267))-^when()who(610,661)'mul(182,139)select()}select()!when();;mul(492,992)?how()~($who(716,562)%/mul(702,654))*>mul(126,386)[mul(351,400)select()%$[!}{+mul(98,266)mul(924,5)*'(^:[}!?mul(112,163)+!?where()mul(987,791)mul(943,488)how()mul(698,312)&:@from(442,439)~%~:mul(235,520)%mul(248,221&>/;select()what()) ~@from()mul(546,261)'mul(956,953why(458,937)when()~!where();mul(442,916)%;)&(mul(410,237)where()~why()[+?[mul(169,337)what()who()&what()mul(901<where()#&who(808,156)-mul(322,634)>/mul* don't()mul(999,662)*]&/'#<+<select(621,69)do()>,^}'mul(365,260){{?,,}from(520,861)where()what()mul(325,208): when()+>{!;mul(335,726)#',:>@?mul(48,443![mul(130,626)!{</#%*select()mul(806,140)'']'~mul(697,649)&,+??[%?how()mul(515,385)mul(878,769)^when()&what()]:$)*%don't()#){/mul(119,439)-[,+!'don't()^<what()~^-[(-%mul(791,824)+>^don't()*?-*[%>mul(934,995),how()@from()'<mul(907,832)?% who()(*[do()%:where()what()>#mul(433,843)why()<}$}how()-mul(754,464)when()why()mul(992,113);]/{%mul(87,293^]how()why()~&when()*#mul(589,979)@-&select()/%mul(218,248);mul(536,581)when()mul(215,212)/%when(66,857)@what()+mul(958,271) '%#who()&{mul(239,197)}what()$>{*'select()mul(365,443)>why()how()what()%mul(885,496how()when()}{@/ mul(589,42)^:;who()where()why() !how()(mul(574,947)*;where():&where()%]<{mul(572,4)$mul(232,716)when()<?>when()mul(928,697)^(where()mul(301,501)-mul(100,436)#~?mul(708,770): @:@)!*mul(89,177)><where()]mul(699,985)(-)do()#who()mul(194,358)why():when()/why()where()mul(103,669)#mul(779,400)@when()~/;/({mul(760,763&-when()%]where()*#mul(781,829)*select()><@+ {when()+mul(926,998);>,)?,$)mul(813,382)}from(728,403)^mul(497,820)where()(?why(454,153)!select()}*!don't()what()from()}&}<?)([mul(379,305)!when(): don't() ~~why()@&%mul(953,224))![*)/mul(802,693):;mul(126,477)-when(409,550){mul(238,713)!/!why()-}+>?how()mul(432,895)$!+mul(743,149)$!why(704,998)when()mul(229,683)((when()from()#&{mul(217,869)^)?)?what() select()}mul(765,209)who():}%{mul(448,553)[:-,don't()what()<,}from()where())mul(543,719)from(415,153)why()!'?^~mul(666,540)mul(922,877)mul(416,636)+#;$select()'mul(971,485)from(964,539)where()^ *who()/mul(35,594)<:mul(207,585)~*}'<when()>[]#mul(815,776){?%&*@?mul(385,133)['!:who() )mul(439,846)&)mul(529;?>;#mul(677,906)^& ()mul(75])how())mul(481,206)who()why()$^ from();what()'why()do()(%^&)mul(277,454)>where()where()$-#select()+/don't()what()select()]mul(295,126)why();from()mul(203,301){#mul(572,420){%(-*mul(929,786)do()mul(107,813)mul(921,668)'^+++!:[;mul(587,921)mul(242,920)mul(933,463)why()mul(340,196)'--']-mul(623,675)select()what()mul(656,927)<$)from()where(473,933)]~mul(408,566)!>$mul(373,541)}%*^)mul(346,14)>&how()@^-(&;mul(993,735)select()*{mul(990,221)*from():[ mul(940,96)/how()^>#;select()/#?mul(624,249)>mul(160,974)]^mul(589,900)&$[?[<-!select()mul(512,717)^/&mul(226,478)* ';'+from()?@~mul(224,929)!when()^what()where()'@'>~mul(451,87)
    \\when()%how()where()how()what() mul(59,36)how()where() )><when()[(mul(776,247)when()# &why())}?mul(331,460)]how()/why(382,926)&*mul(494,482)'*;~#/select()?who(828,76)mul(205,327)~:how(),^how()why()mul(466,546)+'~&mul(481,829?who()!{+who()from()^(%>mul(270,950)--mul(864,193)$!!from()[+when()do()?&]from(){?who()mul(576,443)}>*what()mul(60,617)]where(){*}what(16,936)*:mul(613,575) @$%%'mul(930,241)!~when()<+what()&{mul(189,41)don't()how()%who()how()mul(79,681){']{({ mul(615,354)~#&{mul(863,397)<?;how()mul(264,31>@?(mul(469,991)!mul(97,649)'%{where()/{+*}when()mul(429,913)[ >where()>](when(654,639)),mul(763,148):!~do()%+*',mul(646,831)~*$!?>mul(632 @?from()[mul(165,564)#mul(464,289)from(),mul(197,442)~[&mul(739,935)how()where()!],mul(583,831){mul(4,501)mul(912,584):select()(when()>&& &what()mul(836,498)where(987,400)*${mul(983,648)+~]don't()&,how()'^[*({mul(180,898)mul(982,907): select()($what()mul(294,259)do()where();>mul(130,154)mul(566,682)how()-:from()/ )^mul(50,250)~@select()(->mul(65,434)mul(865,288)+$don't()#+-<when()mul(348,972)#{^*<who()&,mul(545,238)select()mul(736,427)$from()mul(24,605)select():mul(183,229) do()-$where()$where()how()#[why(){mul(440,221)?when(171,776)$mul(930,461)?mul(118,801)how(162,609)where()'why()@ ;:$mul(538,213)>mul(875,123)@@>?mul(606,377);do();!where(){mul(267,543):]','# #*why()mul(31,575)#;who() *<$mul(797,419)'what()}when():what()/mul(627,73)'how(218,429)who()]*$,$from()mul(221,471)$ ;what()mul(38,106)?-&!~&from()mul(117,669):how()mul(422,348)(:/]mul(568,980)when(){~where(490,375)<(& mul'*)'where();##:}mul(34,144)mul(352,352) select()-when()/where(365,161)mul(571,634)mul(373,66)}how()don't()where()@>$$(!&mul(532,260))!mul(304,873)select(676,286)?#<,why(),<!do()/what()]?~^where(558,20)mul(744,233)^''mul(119[/%where()why()%who()mul(797,726)~*why()mul(743,436)?/-why()mul(399,351)mul(398,28))what()(when()/$what(169,128)>^~do()%@~where()mul(56&+select()>select()what()mul(670,288)< $:+<mul(706,866),)when()when()from()mul(391,781)~mul(142,120)>[$~what(){@!%mul(422,126)(who()?from()}*}mul(459,923)mul(38,243)^)!who()::#from()/mul(845,589)^/when()'#when()~,'select()mul(454,166)who()~>when()^when()?'@where()mul(237,855)~from()from()why()mul(233,606)]@mul(947,750)!@*}who()(@%mul(252,951)[from(995,363))}),when()who()+where()mul(368,442)>from()where()select()from()what()^?mul(190,689)mul(337#who()*when()/*mul(652,631);,*why()+select()>}where()%mul(839,296)>&%,@}$mul(723,530)who(685,511) %~where(782,449)mul(36,917);]]{mul@where()!&*%why()mul(191,759):why()what()$mul(900,773):$who() *{mul(426,740) why(396,306)/from()why()*%}'+do()@!'how()%^/mul(970,462)when()who()!-mul(535,35)}from(377,342)when()/(how()who()-}:mul-what()/how()?*^how()mul(217,447)/]?%!mul(495,690)}#<{?,do()+-why()<mul(613,900)<@when()@)from()mul(590,34)-why()mul(524,292)>mul(3,559)who()+what()mul(942,139)})when()who()<-]'what()what()mul(218,316)how()mul(669,389),<+mul(861,165)why(){^}[mul(594,386what()who(){mul(801,662)mul(852,2)-mul(458,479)//mul{don't()mul(826,480)>mul(954,968)$;mul(871,184)from()select()**<]!mul(503,290)#select()where()?do()mul(154%[&how()?mul(279,673)-[don't()$]why()-what(754,13)mul(841,495)where()}{mul<-'##!/usr/bin/perl@~mul?what()<^-@/>from()!mul(573,383)where()-{#mul(420,579)when(977,697)when() &@##from()+}mul(314,487)
    \\who()+from()where()mul(878,982)]~mul(812,80)?select()don't()how()];mul(986,548)/how(311,658)/select()(don't()(select()select(533,328)<^+from()what()why()@mul(786,152)*<[ }},)mul(30,285)mul(721,12)#(-{what()mul(70,496)^when()-/how(420,87)select()what()]$mul(645,406);-~where()>do()~&^(,}$#$mul(993,357)?/select()}do()+from()~@mul(661,590))what()*!?]*!'mul(19,345)-why())select(){%(% don't():*#when()~select()mul(910,416)}mul(550,400)<from();/)$who()mul(107,198)*^;what()*mul(585,659)]}<*[mul(408,612)(how()+'[don't()select()mul(910,993)({[who(895,379)>when()]~mul(515,93)&where()mul(412,99);(;+mul(611,500%what()%,from()when()mul(822,769),-*(([$(mul(153,856)why(){mul(476,25)do()-mul?from()<<[why()&mul(859,60)what()]+ :how()what(434,726):^from()do()}*?}?mul(432,641)>%<why();where()mul(722,325)who()why()do()'$,>?!mul(93,484)++}?mulwho()#>who()select(): why()mul(889,212)>]?where()&mul(808,71)<*/'-+select()mul(523,619)+#where()mul(324,306)why()';why()}mul(337,315)~:what():^?-$from()mul(924,137)mul(444,59)why()[from()how()who()mul/how()>mul(304,707)'select() select()mul(224,915)mul(991,306)[>$! &how()>/mul(719,679)how()select()mul(65,620)from()#'~:]<mul(906,303)}what():how()&%^select():{mul(644,751),^,&,!*'@mul(323,720)why()>+-from()]mul(971,857)how()#[~~]?%mul(230,961)from()from())# } where()mul(330,14)>mul(411,981)}}<)mul(304,453)how()from()$who()mul(573,848)% ;:<mul(23,887)>from()(~select()!mul(542,790)}'#mul(530,502)%$(-#$mul(358,540)mul(10,361)when()where()<}&where()mul(429+!*$~)mul(446,812)%when()don't()>~>^what()select()why()from()where()mul(330,214) -[mul(731,164)/mul(776,235)mul(240,20)who()^what()']@!-who()%don't()(( )'!how()why();>mul(941,911)'?where()from()how()/mul(489,746(select(725,995)-from()?;when()%]%<mul(293,629){;what();(~!<mul(176,456)<~who(252,77)who()~{why()?]&mul(587,279){%?]from()<?mul(313,626)@[/how()+&don't()mul(298,798@!'&when()~(#[mul(827,523)from()$ where()who()%mul(54,803))*mulselect()%mul(500,731)mul(946,993&;{/;where()^where()mul(795,350)where(),~  @^how()-]mul(995,399)%who()do()where()mul(911,909$(?!$]]~what()mul(151,846)[select(636,807)mul(111,19)where(){^mul(730,317)who()^do()'~#]$/$@<>mul(555,315),how()#%!><from();mul(845,939)>?mul(664,596how()+'-who()from(51,408)mul(605,672)?!%from()) #}don't():}mul(579where()mul(243,699)mul(321,902)*!/mul(465,704)*when()[*how()mul-!mul(15,80)}#}mul(413,156)(;mul(71,288)/$;'don't(),how()+[;$who()%$when()mul(516,863)mul(268,600)(</from()~how()'<how()where()mul(715,920)&,mul(989,598)[~where()where()mul(635,110);from()*mul(843,35)&*}@[how(232,546)'-+ mul(979,532)[do()&mul(649,85)]how(832,401)-;mul(876,724)-[mul(432,417)!from()select()]mul(967,886'mul(561,191)#mul(660,865)-}~#mul(736$mul(623,276)from(93,634)^<&-+!@(how()mul(543,427)]#what()from()mul(247,751))from()where()+/^@!;?mul(919,365)where()]&!{-:~why()mul(220,330):]&mul(919,207)-&who()?*how()#%mul(759,323)!how()how()mul(695,755)[{mul(426,127)-{% /~mul '*&how()who()^(mul(797,201)'mul(509from()when()(@(<()don't() :&mul(852,261)<#^]from()mul(981,414)(</who()*do()(+where()*'why()what(229,53)+mul(954,398)mul(148,957)what()^&*mul(92,295)select(){mul(146,508)  who()}[>mul(602,939)who())>)<&'!mul(323,967)?mul(673,398)):&#}>>{!mul(501,484)<;who(969,453)-who(624,921)-)<-mul(72{-//!mul(576,751)mul(318,331)mul(707,186)+how()mul(660#how()!+#?where()mul(547,453)
    \\[what()?->+[mul(266,969)what()from()%^!how()?mul(236,335) )'<>,&!-where()mul(563-select()(mul(405,969)when()[%;why():$]mul(266,763)what()~#-<how()?mul(574,316))^;//}:when()}}mul(798,955)%?(%}*>{+don't()~+-mul(68,150)#{{?%:mul(422,966)select()mul(143,33);mul(917,142))]'>mul(23,457);'what()why()-where()}/>mul(66,911)&&':(>why()>mul(413,27)mul(772,64)mul(266,512)%$<what()who()*-)mul(169,905))where()do()~where(),how()^:what()mul(584,453{#&&:how():,how():%mul(937,5)mul(974+:when()where()~}+-<mul(356,901)~?]when()select()mul(933,555)&'-mul(728,399){&>*[why()<mul(862,418)?>:where(),@%^',mul(750,295)*]:<mul(491,8)#^&mul(801,442)where()where()@/how()+where(17,463)(select()mul(460,732)*what()}/-})>mul(17,60)!!}*from(975,930)mul(763,134)mul(463,381)when()(select()where()+{?what()mul(755,843)!why()+>mul(24,584){mul(105,734)$why()@where()!+what()%what()mul(5,111)#^;?{^/?^~mul(24@>when()what()where()#from(284,9)when(437,59)mul(978,337))+:(select()mul(996,373)(what(188,513)@ ]from()}mul(370,765)~$mul(490,904))]/%who()why()/mul(123,978how()why()[who()~%how(180,982)<mul(251,677)!%(>@:mul(343,157)![/*^mul(157,976)who()from() select()]+?+do();)&)<from()!/select()mul(143,894)]<*,?mul(900,759)]:%@:mul(496,2)*don't())-$# ?!>mul(734,420)$%(select()>'mul(143]mul(4,351)mul(279,828)'}^mul(108,132) #how()why()}mul(573,602)}@mul(747,126)where()'@mul(247>why())when()+::^&from()mul(843,212)^mul(612,743)[mul(204,899)$mul(174,265)%]mul(864,804)-from()how()%%mul(674,431)^^#[(@:&*mul(619,935)select()//~^mul(70,941)why()select(405,825)why()who()@mul(112,658)'+(@!$who(){select()do()from()from()@how(846,925)mul(417,888)~{: who()&-;mul(285,186)-+what(){/+-mul(24,944''mul(935,370)why()?~ +mul(468,38)'why()(/mul(704,512)%mul(946,591,<);from()select(290,495)*{:<do(),)/mul(522,493)(^mul(182,31)/mul(330,74);'%:mul(793,487)-;where()who(){where(590,54)(mulwhen()@ :]!mul(812,795)(:mul(468,59-(how())where()',;mul(263,506);^why()mul(159,826)(,: /$mul(179,478)[,(who()>['%mul(554,965)<why(920,323)mul(3,344)do()]why()mul(353,389)' )+)%from()do()select()#>(~mul(308,534)mul(6,373)^how()@%&how()~mul(669,386)when() 'mul(33,652)mul(950,268)::mul(98,181)]^how()'!mul(982,613)how()&where()]what()how()do()[from()#[? mul(929,452)<$$<who();^]don't()&what()-]}<&from(),~mul(721,96)$}^[what(272,30)&who()mul(107,629)why()why()where()-how()/}from()+mul(718,337) *mul(49,736)why()&/'where(888,569)#&where()]+mul(728,703)!'> mul(506,408)-mul(670,674)how()mul(645,104)do()(>[%from()@'who()&%mul(45,884)mul(895,714)mul(871,6)},?&;!select()#where(779,295)^mul(113,370)why())%[select()[,^' mul(976,960)][%mul(828,993){}}mul(135,443)>what()mul(344,20)>where()/) :@mul(564,715){([,]'mul(675,478)#*@who()>]$*+mul(94,992}<mul(565,578)/mul(85,827)mul(565%do()/+{[mul(956,611)what()mul(807,414)]what()how(521,834)]where()}>from()mul(288,445)mul(72,57)*/})how()[how()!mul(543**%who():what()mul(345,778){mul(462,244)from()[@*who(),+mul(591,870)#select()%mul(779,654)$+%%@ mul(920,934)?-select()-}mul(247,709)@$why()mul(179,824)(when(989,252)?mul(422,816)$[from()#who()<mul(672,845)mul(118,135)
    \\*what()}[*how()?why()mul(386,104)[from()];mul(208,918))){(+<how(),:how()mul(694,384)@!-*{mul(69,248)?',what(), ^<;mul(902,984)*mul(369,924)^?^mul(594,537)>@,when(),mul(922,47)@mulwhy()-mul(890,397)-^/+'select()[&!who()mul(547,6)-]>:^;mul(870,938),~?[%mul(8,689!>*@!]mul(311,244)->how()$when()'}mul(213,766)$:!+ mul(620,644)%where()mul(430,127)%{[mul(682,585)mul(245,26)don't()mul(510,688)where()]-mul(844,443)/@+who()?who()when()mul(453,182)mul(928,131)<select()who()(]mul(422,986)[&&who()[how()$mul(54,860)!]{;mul(549,103)<%;mul(807,173)/mul(513,515)@mul(852,657)'#when(293,457)$&+why()mul(694,888)*why()mul(912,542)$$!:$mul(776,404^$$}&(mul(965,836)-what()*:]mul(97,471)/*~]what(){[what()mul(241,843)where()[^mul(639,208'}(- who()how()mul(869,533)how()who()what()select()%don't() where()(why(811,325)!<where()^~;mul(955,806)][)])+,% mul(207,798):&who(),<where() how()mul(857,424::,]mul(250,416)select()'{mul(815,806)[)/@mul(285,41)$mul(901,755)from()!)?why()){!mul(78>?&'{[+@?,mul(55,18)mul(795,739):}what())@$]'mul(377,34)&,~*why()<do()<mul(795,39)where()$%+?>/@who()mul(467,127))&how(28,925)mul(955,519)}where(830,382)$when()[-why()/+mul(310,139)mul(217,931)!mul(574,122)!mul(227,82)where()mul(940,851) {mul(545,758)<select()?[mul(720,337)mul(52,940)~how()from(855,795)*mul(664,962)>:from()%~/mul(937,897)mul(665,919)^&/  &what()mul(23,37),select()%*mul(98,952);mul(171,967)who()$+]when()%$mul(426,870)<<;;why()[do()@mul(28,286)-what()([+select()why()do()<^+what()^?~-mul(246,992)/mul(938,936)'$>when()mul(18,736)%?how()-what()from() <do()mul(994,498);<,how(800,873)[%/&mul(260,162)why()]when())(what()}#don't() mul(99,24)(*!@]]mul(490,150)~mul(47,794)$#}where()(who(){what():mul(369,830)mul(24,75)where():(,@)]$~mul(509,783)mul(914,160)+mul(619,799)&@~how()from()mul(445,64)*>when()select()mul(37,387)}<[}?+how()#&?mul(779,369)select()mul(750,510)%[,'from()>who()mul(13,97)what(547,477)why(859,962)?,where()mul(806,879)mul(577,179)#from()+>where(705,292)what(712,121))when(227,970)*mul(942,336)& who())!<mul(345,567)/-select(838,572)-~'*)why()[mul(12,866)@^where()?<mul(985,870)where(503,821);^mul(803,551)'[%#where()-who())mul(38,22)^}$who()?,how()%what(528,476)who()mul(486,865)<(/mul(714,503)%%,$select()]mul(299,58)-when()~why()-}mul(684,388) /^<:[;:don't()why()who()<who()-{mul(413,975),>*mul(992,750):from()<:+-mul(938,672)mul(55,872)mul(354,183)>+(+mul(520,932)#from():}{who()$mul(675,973)@^@%mul(58,468)/select()what()->]mul(343,375)^ ,%mul(480,300)where()(/*$mul(695,676)how()where(),-!:from()mul(363,212)~(!where()-[what()don't()mul(614,594))mul(569,802)'mul(995,471)~&$:^:how()how()-^mul(853,428)-;-%what()(from()+do()'where()() !{^?#mul(376,780)select())where()select()&{-,{,mul(894,646)select()*< @}*[}}mul(332,665)[
;

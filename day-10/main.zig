const std = @import("std");
const print = std.debug.print;

const ReachedSummits = [ROWS][COLUMNS]bool;

pub fn main() void {
    const start = std.time.microTimestamp();

    var summits_reachable_for_all_trailheads: u16 = 0;
    var distinct_summit_trails: u16 = 0;
    for (0..ROWS) |y| {
        for (0..COLUMNS) |x| {
            const coord = Coordinate{ .x = x, .y = y };

            if (!coord.isTrailHead()) continue;

            var reached_summits: ReachedSummits = [_][COLUMNS]bool{
                [_]bool{false} ** COLUMNS,
            } ** ROWS;
            distinct_summit_trails += exploreTrail(coord, &reached_summits);
            summits_reachable_for_all_trailheads += sumReachableSummits(&reached_summits);
        }
    }

    print("Summits reachable for all trailheads (Part 1): {}\n", .{summits_reachable_for_all_trailheads});
    print("Distinct trails to summits for all trailheads (Part 2): {}\n", .{distinct_summit_trails});

    const end = std.time.microTimestamp();
    const micros = end - start;
    const millis = @as(f32, @floatFromInt(micros)) / 1000;
    print("\nExecution time: {d:.3}ms\n", .{millis});
}

fn sumReachableSummits(reached_summits: *ReachedSummits) u16 {
    var total: u16 = 0;
    for (reached_summits) |row| {
        for (row) |reached_summit| {
            if (reached_summit) total += 1;
        }
    }
    return total;
}

fn exploreTrail(coordinate: Coordinate, reached_summits: *ReachedSummits) u16 {
    if (coordinate.isHighest()) {
        reached_summits[coordinate.y][coordinate.x] = true;
        return 1;
    }
    var total_summits: u16 = 0;
    const next_steps = coordinate.nextSteps();
    for (next_steps.constSlice()) |next| {
        total_summits += exploreTrail(next, reached_summits);
    }
    return total_summits;
}

const NextSteps = std.BoundedArray(Coordinate, 4);

const Direction = enum(u2) { Left, Up, Right, Down };

const Coordinate = struct {
    x: usize,
    y: usize,

    fn toInputIdx(self: *const Coordinate) usize {
        return self.y * (COLUMNS + 1) + self.x;
    }

    fn getChar(self: *const Coordinate) u8 {
        return input[self.toInputIdx()];
    }

    fn isTrailHead(self: *const Coordinate) bool {
        return self.getChar() == '0';
    }

    fn isHighest(self: *const Coordinate) bool {
        return self.getChar() == '9';
    }

    fn nextSteps(self: *const Coordinate) NextSteps {
        var next_steps = NextSteps.init(0) catch unreachable;
        const directions = [_]Direction{ .Left, .Up, .Right, .Down };
        for (directions) |direction| {
            if (self.getAdjacant(direction)) |adjacent| {
                const adjacent_char = adjacent.getChar();
                const self_char = self.getChar();
                if (adjacent_char <= self_char) {
                    continue;
                }
                if (adjacent_char - self_char != 1) {
                    continue;
                }
                next_steps.append(adjacent) catch unreachable;
            }
        }
        return next_steps;
    }

    fn getAdjacant(self: *const Coordinate, direction: Direction) ?Coordinate {
        switch (direction) {
            .Left => {
                if (self.x == 0) return null;
                return Coordinate{ .x = self.x - 1, .y = self.y };
            },
            .Up => {
                if (self.y == 0) return null;
                return Coordinate{ .x = self.x, .y = self.y - 1 };
            },
            .Right => {
                if (self.x + 1 == COLUMNS) return null;
                return Coordinate{ .x = self.x + 1, .y = self.y };
            },
            .Down => {
                if (self.y + 1 == ROWS) return null;
                return Coordinate{ .x = self.x, .y = self.y + 1 };
            },
        }
    }
};

const COLUMNS = 57;
const ROWS = 57;

const input =
    \\654329854329876510123231016987212010510218565101234510343
    \\789218765010945678754122987878900123424309654345679623490
    \\543201698541232789669003456987210874535698701234388701581
    \\650165467432871694578712012076321965549785698323897632672
    \\569870346501960543209873453125409876678012587610432543543
    \\678761250123451632114562164534012761237703476526501105412
    \\879610167245893101023470079643443450349812345457432236903
    \\965673298436734345652981188712565621056789400348901247894
    \\434789567823321238761892199801874872341019511289187656785
    \\323458478910210679850743056765923985432678521898096105016
    \\012367320154301589012656145678910676563565430787145234127
    \\121032110263469874322347238765876545612346541256230873298
    \\678545021378954365411038389054985434501487632344321964343
    \\569956985489565243506789872123010123676598701015423459652
    \\654877676671278152105698143232131010989687772356910598701
    \\123468964510189067834521032143328325678567887447827654323
    \\003457853031656508921432541089419834509413996530988921013
    \\012346322142347210560210654076508543210302105421243219034
    \\329855412456898723874345789123467658723213489439850108123
    \\410765001387129634987606932345358169654654398701763237654
    \\567892187298034545674517801776549015456765217652304565456
    \\103011296106234589503623410887232102367896900343215694347
    \\234520345787105678212896556992185601298787871298344787298
    \\309639876496221218923287647881096520109696678987650120156
    \\018743212345430307832100238941087412368543567676543210347
    \\329651008758745476542321107632101309454322430125210321298
    \\478010129669876589401498210543291298765011321212345696212
    \\566723234554745654320567641874980787012780876503856787101
    \\345814656765634765210198532965673236323498903454945671012
    \\210905549876589894321983449452360145324567612367834589323
    \\356876632365565923015892158301450765410212143256521985434
    \\547893421245674310234765067201221896784301032103410676965
    \\432012560634789212105604300104334985895212349874306565876
    \\101765676543434301789812215419455854326710458213215678945
    \\569858987612343890176543216328766733210824567303764549432
    \\478945890502345789265674307435432145601939665432876732981
    \\323832781981256776328989438976965032789348778901905891070
    \\210501632870125865410676521089874321011657345877814560565
    \\343412541065434934541541078789289010150069256766923471234
    \\454323401298743327601232369632103210541178129845812984321
    \\565216543345652418796543454543432325652298087234701005630
    \\074307232387651009187452330346501478743367896100565216787
    \\189898101997843218012341021257562569895456545321074323896
    \\234798001876960107345987012368876521080303434538989010143
    \\145667010165456256296456543879989437871212343245698763230
    \\021054323234387340187898534987654306965105650156787654321
    \\430032104101298712345657659654789215456016781235673212452
    \\545145235310132101076740348743690104312167098767654101963
    \\696236996232145098889821289634587431203458129868910017876
    \\587347887145096567986798678723876520104239234776521149887
    \\678956981076787057872107509018987011015145445689432234796
    \\454965438987789142963456410123070187676076323432011005645
    \\567870127695654231254784321212165296589889916501123010434
    \\458765476554514340345697654301254345432127807867834121125
    \\389654389453001234434398941210345452345076321958985034016
    \\210323430302112965525289030367676321456985430843476985107
    \\323014321210227871012100123458983210167890121652105876898
;

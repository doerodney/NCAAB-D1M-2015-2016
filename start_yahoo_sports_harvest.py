from datetime import date, timedelta
import game_url
import team_game
import team_conference
import team_home_court
import time
import xml.etree.ElementTree
from optparse import OptionParser
import urllib

def generate_summary_row(winner, loser):
    winner_court_desc = get_win_court_description(winner, loser)
    winner_common_string = winner.get_common_report_string()
    loser_common_string = loser.get_common_report_string()

    summary_row = '"%s","%s","%s",%s,%s' % \
                  (winner.game_key, winner.game_date, winner_court_desc,
                   winner_common_string, loser_common_string)

    return summary_row

def get_box_score_content(url):
    summary_list = []

    team_list = []
    conference_list = []
    home_court_list = []

    # Get content embedded in the URL.
    url_info = game_url.GameUrl(url)
    first_team_name = url_info.first_team_name
    second_team_name = url_info.second_team_name

    game_key = url_info.game_key
    game_date = url_info.date_text
    court_id = url_info.location_code

    team_list.append(first_team_name)
    team_list.append(second_team_name)

    conference_list.append(team_conference.TeamConference.get_team_conference(first_team_name))
    conference_list.append(team_conference.TeamConference.get_team_conference(second_team_name))

    home_court_list.append(team_home_court.TeamHomeCourt.get_team_home_court_code(first_team_name))
    home_court_list.append(team_home_court.TeamHomeCourt.get_team_home_court_code(second_team_name))

    # Pull in content from the URL.
    response = urllib.urlopen(url)
    url_content = response.read()

    # A box score starts and ends with these.
    target_start = '<h4 '
    target_end = '</table>'

    content_section_list = get_content_section_list(url_content, target_start, target_end)

    if len(content_section_list) > 1:
        # Parse content into TeamGame objects.  These get appended to the
        # summary_list.
        for section in content_section_list:
            summary = team_game.TeamGame()

            start_index = section['start_index']
            length = section['length']
            box_score_content = url_content[start_index : start_index + length]
            tr_start = '<tr>'
            tr_end = '</tr>'
            totals_id = 'table-1-totals'

            # Find the totals id.
            idx_totals_id = box_score_content.find(totals_id, 0)
            idx_tr_start = -1
            idx_tr_end = -1
            totals_text = ''
            if (idx_totals_id > 0):
                # Search backward to find the <tr>.
                idx_tr_start = box_score_content.rfind(tr_start, 0, idx_totals_id)
                if idx_tr_start > 0:
                    # Search forward to find the </tr>.
                    idx_tr_end = box_score_content.find(tr_end, idx_totals_id)
                    if idx_tr_end > 0:
                        totals_text = box_score_content[idx_tr_start : (idx_tr_end + len(tr_end))]
                        parse_box_score_totals(summary, totals_text)
                        summary_list.append(summary)

                # Complain if something is amiss...
                if idx_tr_start < 0 or idx_tr_end < 0:
                    print "Summary data not found for % in %s." % (school_name, url)

            else:
                print "'%s' not found for % in %s." % (totals_id, school_name, url)

        # Iterate the summary list to add external data.
        idx_other = 1
        for i in range(0,2):
            summary_list[i].team = team_list[i]
            summary_list[i].conference = conference_list[i]
            summary_list[i].game_key = game_key
            summary_list[i].game_date = game_date
            summary_list[i].points_allowed = summary_list[idx_other].points_scored
            summary_list[i].set_defensive_rating()
            # Test for home court.  If it is either team's home court then
            # neither team can be on a neutral court.
            if (court_id == home_court_list[i]):
                summary_list[i].home_court = True
                summary_list[i].neutral_court = False
                summary_list[idx_other].neutral_court = False

            idx_other -= 1
    else:
        print 'Content error for %s.' % url

    return summary_list

def get_conference_code_dict():
    conference_code_dict = {
     'America East': 99,
     'Atlantic Coast': 6,
     'Atlantic Ten': 101,
     'Atlantic Sun': 107,
     'American Athletic': 201,
     'Big 12': 103,
     'Big East': 102,
     'Big Sky': 15,
     'Big South': 16,
     'Big Ten': 3,
     'Big West': 8,
     'Colonial Athletic': 17,
     'Conference USA': 1,
     'Horizon League': 34,
     'Independents': 35,
     'Ivy League': 18,
     'Metro Atlantic Athletic': 19,
     'Mid-American': 20,
     'Mid-Eastern': 31,
     'Missouri Valley': 21,
     'Mountain West': 112,
     'Northeast': 32,
     'Ohio Valley': 23,
     'Pac-12':  2,
     'Patriot League': 24,
     'Southeastern': 10,
     'Southland': 28,
     'Southwestern Athletic': 105,
     'Summit': 194,
     'Sun Belt': 5,
     'West Coast': 110,
     'Western Athletic': 111
    }
    return conference_code_dict

def get_conference_game_url_list(conference_url):
    game_url_list = []

    # Pull in content from the URL.
    response = urllib.urlopen(conference_url)
    content = response.read()

    # Look for instances of data-url, as in
    # data-url="/ncaab/rice-owls-washington-state-cougars-201411280632/"
    found_target_list = []
    target = 'data-url'
    idx_found = 0
    while True:
        idx_found = content.find(target, idx_found)
        if idx_found >= 0:
            found_target_list.append(idx_found)
            # Step beyond.
            idx_found += 1
        else:
            break

    # Parse URL from content.
    for start_index in found_target_list:
        url = parse_game_url(content, start_index )
        if len(url) > 0:
            game_url_list.append(url)

    return game_url_list

def get_conference_url_dict(datestamp):
    """ Returns a dictionary of URLs to visit to obtain the results of a conference-day.
        Use this url to look up results for each conference-day combination.
        Look up by conference because yahoo is fussy about getting too much data,
        and they don't (yet) seem to fuss about pulling a conference's data
        for a day.
    """
    conference_url_dict = {}

    # Get the sorted conference names and their Yahoo codes.
    conference_code_dict = get_conference_code_dict()
    conference_name_list = sorted(conference_code_dict.keys())
    for conference_name in conference_name_list:
        # print conference_name
        conference_code = conference_code_dict[conference_name]
        url = str.format('http://sports.yahoo.com/college-basketball/scoreboard/?date={0}&conf={1}',
                         datestamp, conference_code)
        conference_url_dict[conference_name] = url

    return conference_url_dict

def get_content_section_list(content, target_start, target_end):
    idx_search = 0
    idx_found = 0
    idx_start = 0

    content_section_list = []

    while idx_found >= 0:
        # Find the start of the section.
        idx_found = content.find(target_start, idx_search)
        if idx_found >= 0:
            item_start_index = idx_found
            # Step over and resume search.
            idx_search = idx_found + len(target_start)

            # Find the end of the section.
            idx_found = content.find(target_end, idx_search)
            if idx_found >= 0:
                # Calculate index of next search.
                idx_search = idx_found + len(target_end)

                # Record results of search.
                content_section = {}
                content_section['start_index'] = item_start_index
                content_section['length'] = idx_search - item_start_index
                content_section_list.append(content_section)

    return content_section_list

def get_win_court_description(winner, loser):
    desc = 'home'

    if winner.neutral_court == True:
        desc = 'neutral'
    elif loser.home_court == True:
        desc = 'away'

    return desc

def get_data_url_list(datestamp):
    """
    Iterates conference-combinations to get the data urls for each game played
    for a given date.
    """
    data_url_list = []
    conference_url_dict = get_conference_url_dict(datestamp)
    conference_name_list = sorted(conference_url_dict.keys())
    for conference_name in conference_name_list:
        print 'conference: ', conference_name
        conference_url = conference_url_dict[conference_name]
        conference_game_url_list = get_conference_game_url_list(conference_url)
        for game_url in conference_game_url_list:
            print game_url
            data_url_list.append(game_url)

    return sorted(set(data_url_list))

def get_csv_report_header():
    column_header_list = \
        [
            '"game_key"',
            '"date"',
            '"win_court"',
            '"win_team"',
            '"win_conference"',
            '"win_possessions"',
            '"win_points_scored"',
            '"win_offensive_rating"',
            '"win_defensive_rating"',
            '"win_field_goal_fraction"',
            '"win_three_point_fraction"',
            '"win_free_throw_fraction"',
            '"win_offensive_rebounds"',
            '"win_defensive_rebounds"',
            '"win_steals"',
            '"win_blocked_shots"',
            '"win_personal_fouls"',
            '"loss_team"',
            '"loss_conference"',
            '"loss_possessions"',
            '"loss_points_scored"',
            '"loss_offensive_rating"',
            '"loss_defensive_rating"',
            '"loss_field_goal_fraction"',
            '"loss_three_point_fraction"',
            '"loss_free_throw_fraction"',
            '"loss_offensive_rebounds"',
            '"loss_defensive_rebounds"',
            '"loss_steals"',
            '"loss_blocked_shots"',
            '"loss_personal_fouls"'
        ]

    csv_header = ','.join(column_header_list)

    return csv_header

def is_division_one_game(url):
    # Example of a bad URL:
    # http://sports.yahoo.com/ncaab/central-pennsylvania-college-knights-radford-highlanders-201412280483

    result = game_url.GameUrl.is_division_one(url)

    return result

def parse_box_score_totals(summary, totals_xml):
    attrib_name_class = 'class'
    class_field_goals = 'ncaab-stat-type-28 stat-total'
    class_three_pointer = 'ncaab-stat-type-30 stat-total'
    class_free_throws = 'ncaab-stat-type-29 stat-total'
    class_offensive_rebounds = 'ncaab-stat-type-14 stat-total'
    class_defensive_rebounds = 'ncaab-stat-type-15 stat-total'
    class_total_rebounds = 'ncaab-stat-type-16 stat-total'
    class_assists = 'ncaab-stat-type-17 stat-total'
    class_turnovers = 'ncaab-stat-type-20 stat-total'
    class_steals = 'ncaab-stat-type-18 stat-total'
    class_blocked_shots = 'ncaab-stat-type-19 stat-total'
    class_personal_fouls = 'ncaab-stat-type-22 stat-total'
    class_points_scored = 'ncaab-stat-type-13 stat-total'
    class_totals = 'totals'

    # Parse the box score content.
    root = xml.etree.ElementTree.fromstring(totals_xml)
    for td in root.findall('td'):
        attrib_dict = td.attrib
        text = td.text

        if attrib_name_class in attrib_dict.keys():
            class_value = attrib_dict[attrib_name_class]

            if class_value == class_field_goals:
                (made, attempted) = text.split('-')
                summary.field_goals_made = int(made)
                summary.field_goals_attempted = int(attempted)

            elif class_value == class_three_pointer:
                (made, attempted) = text.split('-')
                summary.three_pointers_made = int(made)
                summary.three_pointers_attempted = int(attempted)

            elif class_value == class_free_throws:
                (made, attempted) = text.split('-')
                summary.free_throws_made = int(made)
                summary.free_throws_attempted = int(attempted)

            elif class_value == class_offensive_rebounds:
                summary.offensive_rebounds = int(text)

            elif class_value == class_defensive_rebounds:
                summary.defensive_rebounds = int(text)

            elif class_value == class_total_rebounds:
                summary.total_rebounds = int(text)

            elif class_value == class_assists:
                summary.assists = int(text)

            elif class_value == class_turnovers:
                summary.turnovers = int(text)

            elif class_value == class_steals:
                summary.steals = int(text)

            elif class_value == class_blocked_shots:
                summary.blocked_shots = int(text)

            elif class_value == class_personal_fouls:
                summary.personal_fouls = int(text)

            elif class_value == class_points_scored:
                summary.points_scored = int(text)

    # At this point, all data should be available.
    summary.estimate_possessions()
    summary.set_offensive_rating()

    return summary

def parse_game_url(content, start_index):
    """
    start_index is the index of the 'd' in data-url, as in
    data-url="/ncaab/rice-owls-washington-state-cougars-201411280632/"
    """
    game_url = ''

    # Find the index of the next double quote.
    target = '"'
    quote_idx_list = []
    idx = start_index
    for i in range(0,2):
        idx = content.find(target, idx)
        if idx > 0:
            quote_idx_list.append(idx)
            idx += 1
        else:
            break

    # At this point, if we have two quotes, we can get the url.

    header = 'http://sports.yahoo.com'
    guts = ''
    if len(quote_idx_list) == 2:
        guts = content[(quote_idx_list[0] + 1) : (quote_idx_list[1] - 1)]
        game_url = header + guts
        print game_url

    return game_url

def main():
    # Get year, month, day args for yesterday.
    yesterday = date.today() - timedelta(1)
    year = yesterday.year
    month = yesterday.month
    day = yesterday.day

    parser = OptionParser()
    parser.add_option('-y', '--year', dest='year',
                      help='Year of data to acquire.', default='')
    parser.add_option('-m', '--month', dest='month',
                      help='Month of data to acquire.',
                      default='')
    parser.add_option('-d', '--day', dest='day',
                      help='Day of data to acquire.',
                      default='')

    # Get year month day from options.
    (options, args) = parser.parse_args()
    if options.year != '':
        year = int(options.year)
    if options.month != '':
        month = int(options.month)
    if options.day != '':
        day = int(options.day)

    # If year, month, day args are not fully defined, use yesterday.
    if year == None or month == None or day == None:
        yesterday = date.today() - timedelta(1)
        year = yesterday.year
        month = yesterday.month
        day = yesterday.day

    datestamp = str.format('{0}-{1}-{2}',
        str(year), str(month).zfill(2), str(day).zfill(2))
    print 'Acquiring data for ', datestamp

    data_url_list = get_data_url_list(datestamp)
    #data_url_list = ['http://sports.yahoo.com/ncaab/cal-state-fullerton-titans-hawaii-rainbow-warriors-201502140246']
    #                 'http://sports.yahoo.com/ncaab/lipscomb-bisons-chattanooga-mocs-201412290581']
    #                 'http://sports.yahoo.com/ncaab/temple-owls-villanova-wildcats-201412140617']

    date_result_list = []
    csv_header = get_csv_report_header()
    date_result_list.append(csv_header)

    print 'There are %s URLs to process.' % str(len(data_url_list))

    processed_count = 0

    for url in data_url_list:
        processed_count += 1
        if is_division_one_game(url):

            # Get a game summary for the winner and the loser.
            summary_list = get_box_score_content(url)
            if len(summary_list) == 2:
                # Gross, half wrong assumption about winner and loser.
                winner = summary_list[1]
                loser = summary_list[0]

                # Correct assumption as necessary.
                if summary_list[0].points_scored > summary_list[1].points_scored:
                    winner = summary_list[0]
                    loser = summary_list[1]

                # Generate a report string.
                row_text = generate_summary_row(winner, loser)
                date_result_list.append(row_text)
                print '(%s/%s)  %s' % (str(processed_count), str(len(data_url_list)),  row_text)

    if len(date_result_list) > 1:
        result_file_name = 'Results-%s.csv' % (datestamp)
        file = open(result_file_name, 'w')
        for result in date_result_list:
            file.write('%s\n' % result)
        file.close()

main()


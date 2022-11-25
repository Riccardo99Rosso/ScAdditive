(
s.waitForBoot({

	var synth_freq, current_drone, drone_wave, play_button_action, curve_array = [];

	var win, paint_view;
	var win_pos_x = 100, win_pos_y = 200, win_height = 600, win_width = 1000,
	paint_view_height = win_height, paint_view_width =  win_width / 1.5;
	var clicked, relative_where, pos;
	var red = 0, green = 0, blue = 1, red_pen = 0, green_pen = 204, blue_pen = 0;
	var all_circles = [], all_circles_color = [], all_circles_sound = [],
	all_circles_volume = [];
	var all_circles_center = [], all_swings_speed = [], all_swings_r = [];
	var color_slider, color_changer, color_tmp, i_tmp, already_done = false,
	never_done = true, not_found = true;
	var play_button, choosed_pen;
	var drone_menu, drone_menu_height = 50, drone_menu_width = 200;
	var pen_menu, mode_menu, op_menu, point;
	var drone_volume_menu, circles_volume_menu, drone_volume, circles_volume,
	master_volume, last_clicked, tmp_value;
	var master_set = false, slave_set = false, master, slave;
	var all_swings = [], distance, m;
	var swing_r, swing_speed, swing_r_slider, swing_speed_slider, simmetry = [];
	var swing_r_text, swing_speed_text;
	var master_found, slave_found, run = true;
	var list_of_forked = [], count_forked = [], is_alive, created_counter = 0;
	var removed, routines, range_max = 120, close_all;
	var rec_button, recorder, end_rec_win, show_end_rec_win = true, rec_text,
	dont_show_end_rec_win, dialog_file = false, buffer_file;
	var master_vol, file_synth;
	var open_file, save_file, save_function, open_function, file, file_path = nil;
	var save_new_file, create_saved_file, buffer_one, buffer_two, buffer_three;
	var auto_insert_file, all_contents, list_contents, counter, auto_pen_file;
	var insert_function, auto_x, auto_y, auto_color, auto_r, auto_volume, auto_speed;
	var my_id_auto, app_name, pen_m_item_auto;

	/*
	**********SYNTH**********
	*/
	curve_array = [1, -2, -3];

	SynthDef(\help_PlayBuf, {| out = 0, bufnum = 0 |
		Out.ar(out,
			PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 1, doneAction: Done.freeSelf)
		);
	}).add;

	SynthDef(\circle_note_1, {
		arg freq=220, width=0.5, amp=0.15, length=1, num_harm = 20, gate = 1;
		var sig, env;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 1, 0],
				[0.2, 0.2, 0.2],
				curve_array,
				2
			),
			gate,
			doneAction: 2;
		);
		sig = Blip.ar(freq, num_harm, amp);
		sig = sig * env;
		Out.ar(0, (sig * amp) !2);
	}).add;

	/*Synth dente di sega*/
	SynthDef.new(\basic_saw, {
		arg freq = 440, amp = 0.01, fil_freq = 20000, gate = 1, rq = 0.025;
		var sig, env, out;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 1, 0],
				[0.2, 0.2, 0.2],
				curve_array,
				2
			),
			gate,
			doneAction: 2;
		);
		sig = Saw.ar(freq, mul: amp);
		sig = RLPF.ar(sig, fil_freq, rq);
		sig = sig * env;
		out = Out.ar(0, sig!2);

	}).add;

	SynthDef.new(\tri_wave, {
		arg freq = 440, amp = 0.01, fil_freq = 20000, gate = 1, rq = 0.025;
		var sig, env, out;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 1, 0],
				[0.2, 0.2, 0.2],
				curve_array,
				2
			),
			gate,
			doneAction: 2;
		);
		sig = LFTri.ar(freq, mul: amp);
		sig = RLPF.ar(sig, fil_freq, 0.025);
		sig = sig * env;
		out = Out.ar(0, sig!2);

	}).add;

	SynthDef.new(\sin_wave, {
		arg freq = 440, amp = 0.01, fil_freq = 20000, gate = 1, rq = 0.025;
		var sig, env, out;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 1, 0],
				[0.2, 0.2, 0.2],
				curve_array,
				2
			),
			gate,
			doneAction: 2;
		);
		sig = SinOsc.ar(freq, mul: amp);
		sig = sig * env;
		out = Out.ar(0, sig!2);

	}).add;

	current_drone = \basic_saw;

	/*
	**********GUI**********
	*/

	win = Window.new("MiniRik", Rect(win_pos_x, win_pos_y, win_width, win_height),
		resizable: false);
	app_name = "MiniRic -";
	win.name = (app_name + "unsaved.ric");
	win.acceptsMouseOver = true;
	paint_view = UserView(win, Rect(0, 0, paint_view_width, paint_view_height));
	paint_view.background = Color.white;

	color_changer = { paint_view.background_(Color.new(red, green, blue, 1))};
	color_slider = Slider.new(win, Rect(win_width / 1.5, 0, 40, win_height));
	color_slider.value_(1);
	color_slider.action = {
		green = color_slider.value;
		red = color_slider.value;
		color_changer.value;
		if((play_button.value == 1) && (drone_menu.item != "drone: file"), {
			synth_freq = 40 + (150 * color_slider.value);
			drone_wave.set(\fil_freq, 55 + (20000 * color_slider.value));
			drone_wave.set(\freq, synth_freq);
		});
	};

	last_clicked = 0;

	circles_volume = Slider.new(win, Rect(win_width / 1.5 + 50, 70, 50, 170));
	circles_volume.value_(0.15);
	circles_volume.action = {
		all_circles_volume[last_clicked] = circles_volume.value;
		all_circles_sound[last_clicked].set(\amp, circles_volume.value);
	};

	//all_swings_speed = [0];
	//all_swings_r = [0];

	swing_r_text = StaticText(win, Rect(win_width / 1.5 + 50, 260, 260, 20));
	swing_r_text.string = "Circle range:";
	swing_r_slider = Slider.new(win, Rect(win_width / 1.5 + 50, 280, 260, 20));
	swing_r_slider.orientation_(\horizontal);
	swing_r_slider.value_(0);
	swing_r_slider.action = {
		arg value;
		all_swings_r[last_clicked] = swing_r_slider.value;
	};
	//swing_r_slider.action.value;

	swing_speed_text = StaticText(win, Rect(win_width / 1.5 + 50, 310, 260, 20));
	swing_speed_text.string = "Circle speed:";
	swing_speed_slider = Slider.new(win, Rect(win_width / 1.5 + 50, 330, 260, 20));
	swing_speed_slider.orientation_(\horizontal);
	swing_speed_slider.value_(0);
	swing_speed_slider.action = {
		all_swings_speed[last_clicked] = swing_speed_slider.value;
	};
	//swing_speed_slider.action.value;

	drone_volume = Slider();
	drone_volume.orientation_(\horizontal);
	drone_volume.value_(0.1);
	drone_volume.action = {
		drone_wave.set(\amp, drone_volume.value);
	};

	drone_volume_menu = Menu(MenuAction.separator.string_("drone volume"),
		CustomViewAction(drone_volume));

	close_all = Button.new(win, Rect(win_width / 1.5 + 50, 550, 260, 40)).states_([
		["Clear all", Color.black, Color.new255(245, 80, 80)],
		["Clear all", Color.black, Color.new255(245, 80, 80)]]);
	close_all.action = {

		routines = routines.do({
			arg elem, i;
			elem.stop;
		});

		s.freeAll;
		all_circles_sound = [];
		all_circles_volume = [];
		all_swings_r = [];
		all_swings_speed = [];
		all_circles = [];
		all_circles_center = [];
		all_circles_color = [];
		simmetry = [];
		if(play_button.value == 1) {
			drone_wave.set(\gate, 0);
			file_synth.free;
			play_button.value = 0;
		};
		win.refresh;
	};

	create_saved_file = {
		file = File.new(file_path, "w");
		for(0, (all_circles.size - 1)) {
			arg i;
			file.write(
				simmetry[i].x.asString ++ "#" ++
				simmetry[i].y.asString ++ "#";
			);
			file.write(all_circles_color[i].asString ++ "#");
			file.write(all_circles_volume[i].asString ++ "#");
			file.write(all_swings_r[i].asString ++  "#");
			file.write(all_swings_speed[i].asString ++ "#");
		};
		file.close;
		"Salvataggio effettuato".postln;
	};

	save_function = {
		file_path.postln;
		if(file_path == nil) {
			Dialog.savePanel(
				{ arg path;
					file_path = path;
					file_path.postln;
					buffer_one = file_path.split($.);
					buffer_two = file_path.split($/);
					win.name = (app_name + buffer_two[(buffer_two.size - 1)]);
					create_saved_file.value();
				},
				{
					"cancelled".postln;
				}
			);
		};
		if(file_path.notNil) {
			create_saved_file.value()
		};
	};
	/*
	paint_view.keyDownAction = { |doc, char, mod, unicode, keycode, key|
	if(key == 83) {
	save_function.value();
	};
	};
	*/
	master_vol = Button.new(win, Rect(win_width / 1.5 + 200, 400, 110, 40)).states_([
		["Master volume", Color.black,Color.new255(85, 187, 225)],
		["Master volume", Color.black, Color.new255(85, 187, 225)]]);
	master_vol.action = {
		s.volume.gui;
	};

	open_file = Button.new(win, Rect(win_width / 1.5 + 50, 400, 110, 40)).states_([
		["Open", Color.black, Color.new255(0, 200, 153)],
		["Open", Color.black, Color.new255(0, 200, 153)]]);

	open_file.action = {
		FileDialog({ |paths|
			buffer_one = paths[0].split($.);
			buffer_two = paths[0].split($/);
			if(buffer_one[(buffer_one.size - 1)] == "ric") {
				win.name = (app_name + buffer_two[(buffer_two.size - 1)]);
				file_path = paths[0];
				file = File.new(file_path, "r");
				all_contents = file.readAllString;
				list_contents = all_contents.split($#);
				for(0, (list_contents.size - 1)) {
					arg i;
					if(list_contents[i] == "") {
						list_contents.removeAt(i);
					};
				};
				forBy(0, (list_contents.size - 1), 6) {
					arg i, k;
					counter = 0;
					last_clicked = k;
					for(0, 5) {
						arg j;
						//list_contents[j].postln;
						if(j == 0){
							auto_x = list_contents[(i + j)].asInteger;
						};
						if(j == 1){
							auto_y = list_contents[(i + j)].asInteger;
						};
						if(j == 2){
							if(list_contents[(i + j)] == "Color(0.0, 0.8)") {
								auto_color = list_contents[(i + j)].asInteger;
								red_pen = 0;
								green_pen = 204;
								blue_pen = 0;
								auto_pen_file = 0;
							};
							if(list_contents[(i + j)] == "Color(1.0)") {
								auto_color = list_contents[(i + j)].asInteger;
								red_pen = 255;
								green_pen = 0;
								blue_pen = 0;
								auto_pen_file = 1;
							};
							if(list_contents[(i + j)] == "Color(1.0, 0.6, 0.2)") {
								auto_color = list_contents[(i + j)].asInteger;
								red_pen = 255;
								green_pen = 153;
								blue_pen = 51;
								auto_pen_file = 2;
							};
							if(list_contents[(i + j)] == "Color(0.0, 0.8, 0.8)") {
								auto_color = list_contents[(i + j)].asInteger;
								red_pen = 0;
								green_pen = 204;
								blue_pen = 204;
								auto_pen_file = 3;
							};
						};
						if(j == 3){
							auto_volume = list_contents[(i + j)].asFloat;
						};
						if(j == 4){
							auto_r = list_contents[(i + j)].asFloat;
						};
						if(j == 5){
							auto_speed = list_contents[(i + j)].asFloat;
						};
					};
					//auto_pen_file.postln;
					my_id_auto = k;
					swing_r_slider.value = auto_r;
					swing_speed_slider.value = auto_speed;
					insert_function.value(auto_x, auto_y, auto_pen_file,
						auto_r, auto_speed, auto_volume, my_id_auto);
					//insert_function.value(auto_, 100, 1, 0.0, 0.0, 0.15);
				};
			};
		}, {
			postln("Dialog was cancelled. Try again.");
		});
	};

	save_file = Button.new(win, Rect(win_width / 1.5 + 50, 450, 110, 40)).states_([
		["Save", Color.black, Color.green],
		["Save", Color.black, Color.green]]);

	save_file.action = {
		save_function.value();
	};

	save_new_file = Button.new(win, Rect(win_width / 1.5 + 200, 450, 110, 40)).states_([
		["Save new", Color.black, Color.green],
		["Save new", Color.black, Color.green]]);

	save_new_file.action = {
		Dialog.savePanel({ arg path;
			file_path = path;
			file_path.postln;
			buffer_one = file_path.split($.);
			buffer_two = file_path.split($/);
			win.name = (app_name + buffer_two[(buffer_two.size - 1)]);
			create_saved_file.value();
		},{
			"cancelled".postln;
		});
	};

	rec_button = Button.new(win, Rect(win_width / 1.5 + 50, 500, 260, 40)).states_([
		["Push to rec", Color.black, Color.new255(205, 132, 132)],
		["Recording in progress...", Color.black, Color.new255(255, 0, 0)]]);
	rec_button.font_(Font("Impact", 14));
	rec_button.action = {
		if (rec_button.value == 1,
			{
				recorder = Recorder(s).recHeaderFormat = "wav";
				recorder.record;

			},
			{
				recorder.stopRecording;

				if(show_end_rec_win == true) {
					end_rec_win = Window.new("Registration finished",
						Rect(200, 600, 440, 150));
					rec_text = TextView(end_rec_win, Rect(20, 10, 400, 80));
					rec_text.font_(Font("Bahnschrift", 14));
					rec_text.string = "La registrazione è stata salvata in:\n" +
					thisProcess.platform.recordingsDir;
					dont_show_end_rec_win = Button(end_rec_win,
						Rect(20, 100, 300, 40)).states_([
						["Non mostrare più in questa sessione",
							Color.black, Color.new255(102, 102, 255)],
						["Non mostrare più in questa sessione",
							Color.black, Color.new255(102, 102, 255)]]);
					dont_show_end_rec_win.action = {
						show_end_rec_win = false;
						end_rec_win.close;
					};
					end_rec_win.alwaysOnTop = true;
					end_rec_win.front;
				};
			}
		);
	};


	play_button = Button.new(win, Rect((win_width / 1.5) + 50, 10, 50, 50)).states_([
		["drone \non", Color.black, Color.new255(85, 187, 225)],
		["drone \noff", Color.black, Color.new255(230, 106, 135)]]);
	play_button.mouseDownAction = { |v, x, y, mod, button|
		if(button.value == 1) {
			drone_volume_menu.front;
		}
	};
	drone_menu =PopUpMenu(win, Rect((win_width / 1.5) + 110, 10, drone_menu_width,
		drone_menu_height));
	drone_menu.items = [
		"drone: Saw wave", "drone: Triangular wave", "drone: Sinusoidal wave", "drone: file"
	];

	drone_menu.action = {
		arg menu;
		current_drone = case
		{menu.item == "drone: Saw wave"} {\basic_saw}
		{menu.item == "drone: Triangular wave"} {\tri_wave}
		{menu.item == "drone: Sinusoidal wave"} {\sin_wave}
		{menu.item == "drone: file"} {\help_PlayBuf};
		if(play_button.value == 1) {
			drone_wave.set(\gate, 0);
			play_button.action.value();
		};
		dialog_file = false;
		if(menu.item == "drone: file") {
			(
				dialog_file = true;
				if(play_button.value == 1) {
					drone_wave.set(\gate, 0);
				};
			)
		};
		if(menu.item != "drone: file") {
			if(play_button.value == 1) {
				file_synth.free;
			};
		}
	};

	drone_menu.mouseDownAction = { |v, x, y, mod, button|
		if ((dialog_file == true) && (button.value == 1)) {
			FileDialog({ |paths|
				file_synth.free;
				buffer_file = Buffer.read(s, paths[0]);
				if(play_button.value == 1) {
					file_synth = Synth(\help_PlayBuf, args: [\bufnum, buffer_file]);
				};
			}, {
				postln("Dialog was cancelled. Try again.");
			});
		}
	};

	play_button.action = {
		arg butt;
		if(play_button.value == 1,
			{
				synth_freq = 40 + (150 * color_slider.value);
				if ( current_drone == \basic_saw,
					{
						drone_wave = Synth.new(\basic_saw, [\freq, synth_freq,
							\amp, drone_volume.value,
							\fil_freq, 55 + (20000 * color_slider.value)]);
					}
				);
				if (current_drone == \tri_wave,
					{
						drone_wave = Synth.new(\tri_wave, [\freq, synth_freq, \amp,
							drone_volume.value,
							\fil_freq, 55 + (20000 * color_slider.value)]);
					}
				);
				if (current_drone == \sin_wave,
					{
						drone_wave = Synth.new(\sin_wave, [\freq, synth_freq, \amp,
							drone_volume.value, \fil_freq, 200]);
					}
				);
				if (current_drone == \help_PlayBuf,
					{
						file_synth = Synth(\help_PlayBuf, args: [\bufnum, buffer_file]);
					}
				);

			},
			{
				drone_wave.set(\gate, 0);
				file_synth.free;
			}
		)
	};

	pen_menu = PopUpMenu(win, Rect((win_width / 1.5) + 110, 10 + drone_menu_height + 10,
		drone_menu_width, drone_menu_height));
	pen_menu.items = [
		"pen: blip", "pen: saw", "pen: triangular", "pen: sinusoidal"
	];

	pen_menu.action = {
		arg menu;
		if (menu.item == "pen: blip", {
			//green
			choosed_pen = \circle_note_1;
			red_pen = 0;
			green_pen = 204;
			blue_pen = 0;
		});
		if (menu.item == "pen: saw", {
			//red
			choosed_pen = \basic_saw;
			red_pen = 255;
			green_pen = 0;
			blue_pen = 0;
		});
		if (menu.item == "pen: triangular", {
			//orange
			choosed_pen = \tri_wave;
			red_pen = 255;
			green_pen = 153;
			blue_pen = 51;
		});
		if (menu.item == "pen: sinusoidal", {
			//blue skye
			choosed_pen = \sin_wave;
			red_pen = 0;
			green_pen = 204;
			blue_pen = 204;
		});
		pen_menu.stringColor_(Color.new255(red_pen, green_pen, blue_pen));
	};
	pen_menu.stringColor_(Color.new255(red_pen, green_pen, blue_pen));


	mode_menu = PopUpMenu(win, Rect((win_width / 1.5) + 110, 130, drone_menu_width,
		drone_menu_height));

	mode_menu.items = [
		"mode: circles", "mode: draw"
	];

	op_menu = PopUpMenu(win, Rect((win_width / 1.5) + 110, 190, drone_menu_width,
		drone_menu_height));

	op_menu.items = [
		"operation: insert", "operation: move", "operation: delete"
	];

	paint_view.drawFunc = {
		|v, x, y|
		point = [x,y];
		//"draw".postln;
		all_circles.do { |elem, i|
			Pen.addOval(elem);
			//all_circles_color[i].class.postln;
			Pen.color = all_circles_color[i];
			Pen.draw;
		};
	};

	paint_view.mouseUpAction = {
		if(mode_menu.item == "mode: circles" &&
			op_menu.item != "operation: delete"&& clicked.notNil) {
			all_circles_color[clicked] = color_tmp;
			win.refresh;
		};
		clicked = nil;
	};

	insert_function = {
		arg x, y, auto_pen = -1, r_val = 0, speed_val = 0, volume_val = 0.15, id = -1;
		if(auto_pen == 0) {
			pen_m_item_auto = "pen: blip";
		};
		if(auto_pen == 1) {
			pen_m_item_auto = "pen: saw";
		};
		if(auto_pen == 2) {
			pen_m_item_auto = "pen: triangular";
		};
		if(auto_pen == 3) {
			pen_m_item_auto = "pen: sinusoidal";
		};
		if(auto_pen == -1){
			pen_m_item_auto = pen_menu.item;
		};

		all_circles = all_circles.add(
			Rect(x,y,20,20);
		);
		simmetry = simmetry.add(Point(x, y));
		all_circles_center = all_circles_center.add(Point(x, y));
		all_circles_color = all_circles_color.add(
			Color.new255(red_pen, green_pen, blue_pen);
		);
		created_counter = created_counter + 1;
		if (((pen_m_item_auto == "pen: blip") || (auto_pen == 0)),
			{
				all_circles_sound = all_circles_sound.add(
					Synth(\circle_note_1, [
						\freq, x + 40,
						\num_harm, (win_height - y) / 30,
						\amp, volume_val
					]);
				);
				all_circles_volume = all_circles_volume.add(volume_val);
				all_swings_r = all_swings_r.add(r_val);
				all_swings_speed = all_swings_speed.add(speed_val);
				last_clicked = all_circles.size - 1;
				circles_volume.value = all_circles_volume[last_clicked];
				swing_r_slider.value = all_swings_r[last_clicked];
				swing_speed_slider.value = all_swings_speed[last_clicked];

		});
		if (((pen_m_item_auto == "pen: saw") || (auto_pen == 1)), {
			all_circles_sound = all_circles_sound.add(
				Synth(\basic_saw, [
					\freq, x + 40,
					\rq, 0.8,
					\fil_freq, 100 * (win_height - y)/10,
					\amp, volume_val
				]);
			);
			//all_circles_sound[all_circles.size - 1].postln;
			all_circles_volume = all_circles_volume.add(volume_val);
			all_swings_r = all_swings_r.add(r_val);
			all_swings_speed = all_swings_speed.add(speed_val);
			last_clicked = all_circles.size - 1;
			circles_volume.value = all_circles_volume[last_clicked];
			swing_r_slider.value = all_swings_r[last_clicked];
			swing_speed_slider.value = all_swings_speed[last_clicked];

		});
		if (((pen_m_item_auto == "pen: triangular") || (auto_pen == 2)), {
			all_circles_sound = all_circles_sound.add(
				Synth(\tri_wave, [
					\freq, x + 40,
					\rq, 1,
					\fil_freq, 100 * (win_height - y)/10,
					\amp, volume_val
				]);
			);
			all_circles_volume = all_circles_volume.add(volume_val);
			all_swings_r = all_swings_r.add(r_val);
			all_swings_speed = all_swings_speed.add(speed_val);
			last_clicked = all_circles.size - 1;
			circles_volume.value = all_circles_volume[last_clicked];
			swing_r_slider.value = all_swings_r[last_clicked];
			swing_speed_slider.value = all_swings_speed[last_clicked];
		});
		if (((pen_m_item_auto == "pen: sinusoidal") || (auto_pen == 3)), {
			all_circles_sound = all_circles_sound.add(
				Synth(\sin_wave, [
					\freq, x + 40,
					\amp, volume_val
				]);
			);
			all_circles_volume = all_circles_volume.add(volume_val);
			all_swings_r = all_swings_r.add(r_val);
			all_swings_speed = all_swings_speed.add(speed_val);
			last_clicked = all_circles.size - 1;
			circles_volume.value = all_circles_volume[last_clicked];
			swing_r_slider.value = all_swings_r[last_clicked];
			swing_speed_slider.value = all_swings_speed[last_clicked];
		});
		if(((pen_m_item_auto == "pen: blip") || (auto_pen == 0)) ||
			((pen_m_item_auto == "pen: saw") || (auto_pen == 1)) ||
			((pen_m_item_auto == "pen: triangular") || (auto_pen == 2)) ||
			((pen_m_item_auto == "pen: sinusoidal") || (auto_pen == 3)))
		{
			//postf("ultiMo cliccato: %\n", last_clicked);

			routines = routines.add({

				var mini_count;
				var my_id = created_counter;
				var to_right = true, to_left = false;
				var my_x = x, my_y = y;
				var size = routines.size;

				if(id != -1) {
					last_clicked = id;
					postf("last: %\n", id);
				};

				mini_count = last_clicked;
				/*
				("my speed" + speed_val.asString).postln;
				("my r" + r_val.asString).postln;
				all_swings_r.postln;
				"-------".postln;
				all_swings_r[mini_count].postln;
				"-------".postln;
				all_swings_speed[mini_count].postln;
				"-------".postln;

				postf("ultimo cliccato: %\n", mini_count);
				*/
				while {true} {
					//size.postln;
					if(size > routines.size) {
						mini_count = mini_count - 1;
						size = size - 1;
						"......................................".postln;
					};

					if((all_swings_speed[mini_count] != 0) &&
						(all_swings_r[mini_count] != 0)){
						r = all_circles.at(mini_count);

						if(r.origin.x == 0) {
							all_circles.put(mini_count, r.origin =
								Point(r.origin.x + 1, r.origin.y));
							all_circles_center[mini_count] = Point(r.origin + 1,
								r.origin.y);
							to_right = true;
							to_left = false;
						};
						if(r.origin.x >
							(win_width / 1.5)) {
							to_left = true;
							to_right = false;
							all_circles.put(mini_count, r.origin =
								Point((win_width / 1.5), r.origin.y));
							all_circles_center[mini_count] = Point((win_width /
								1.5),
							r.origin.y);
						};

						if((to_right && (r.origin.x <=
							(simmetry[mini_count].x + (range_max *
								all_swings_r[mini_count]))) && (r.origin.x <=
							(win_width / 1.5)) && (r.origin.x > 0)),
						{
							all_circles.put(mini_count, r.origin =
								Point(r.origin.x + 1, r.origin.y));
							all_circles_center[mini_count] = Point(r.origin + 1,
								r.origin.y);
							all_circles_sound[mini_count].set(
								\freq, r.origin.x + 40,
							);
							//mini_count.postln;
							if((r.origin.x >=
								(simmetry[mini_count].x + (range_max *
									all_swings_r[mini_count]))) || (r.origin.x >
								(win_width / 1.5)) || (r.origin.x <= 0)) {
								to_right = false;
								to_left = true;
								if(r.origin.x <= 0) {
									all_circles.put(mini_count, r.origin =
										Point(r.origin.x + 1, r.origin.y));
									all_circles_center[mini_count] = Point(r.origin + 1,
										r.origin.y);
									to_right = true;
									to_left = false;
								};
								if(r.origin.x >
									(win_width / 1.5)) {
									all_circles.put(mini_count, r.origin =
										Point((win_width / 1.5), r.origin.y));
									all_circles_center[mini_count] =
									Point((win_width / 1.5),
										r.origin.y);
									to_left = true;
									to_right = false;
								};
							};
							win.refresh;
						},
						{
							if(to_left && (r.origin.x >=
								(simmetry[mini_count].x - (range_max *
									all_swings_r[mini_count])) && (r.origin.x <=
									(win_width / 1.5)) && (r.origin.x > 0)),
							{
								all_circles.put(mini_count, r.origin =
									Point(r.origin.x - 1, r.origin.y));
								all_circles_center[mini_count] = Point(r.origin - 1,
									r.origin.y);

								all_circles_sound[mini_count].set(
									\freq, r.origin.x + 40,
								);
								win.refresh;
							},
							{
								to_left = false;
								to_right = true;
								if(r.origin.x <= 0) {
									r.origin.x = 1;
									to_right = true;
									to_left = false;
								};
								if(r.origin.x >
									(win_width / 1.5)) {
									r.origin.x = (win_width / 1.5);
									to_left = true;
									to_right = false;
								};
								win.refresh;
							}
							);
						}
						);
						((1 - all_swings_speed[mini_count])/4).wait;
					};
					if((all_swings_speed[mini_count] == 0) ||
						(all_swings_r[mini_count] == 0)) {
						0.2.wait;
					};
				};
			}.fork(AppClock););
		};
		win.refresh;
	};

	paint_view.mouseDownAction = { |v, x, y, mod, button|
		if(mode_menu.item == "mode: circles") {
			already_done = false;
			all_circles.do { |rect, i|
				if(already_done == false && rect.contains(Point(x, y))) {
					//"qua".postln;
					clicked = i;
					last_clicked = i;
					if(op_menu.item != "operation: delete") {
						color_tmp = all_circles_color[clicked];
						all_circles_color[clicked] = Color.yellow;
					};
					relative_where = Point(x, y) - rect.origin;
					already_done = true;
					circles_volume.value = all_circles_volume[clicked];
					swing_r_slider.value = all_swings_r[clicked];
					swing_speed_slider.value = all_swings_speed[clicked];
					win.refresh;
				};
			};
		};

		if(clicked == nil) {
			master_set = false;
			slave_set = false;
		};
		if(mode_menu.item == "mode: circles" && op_menu.item == "operation: insert") {
			x = x - 10;
			y = y - 10;
			insert_function.value(x, y);
		};
		if(mode_menu.item == "mode: circles" && op_menu.item == "operation: delete"){
			if(clicked.notNil) {
				all_circles_sound[clicked].set(\gate, 0);
				all_circles_sound.removeAt(clicked);
				all_circles_volume.removeAt(clicked);
				all_swings_r.removeAt(clicked);
				all_swings_speed.removeAt(clicked);

				routines[clicked].stop;
				routines.removeAt(clicked);

				all_circles.removeAt(clicked);
				all_circles_center.removeAt(clicked);
				all_circles_color.removeAt(clicked);
				win.refresh;
			}
		};
	};
	paint_view.mouseMoveAction = { |v, x, y|
		var rect;
		if(mode_menu.item == "mode: circles" && op_menu.item == "operation: move") {
			if(clicked.notNil && (x > 0) && (x < (win_width / 1.5)) && (y > 0) &&
				(y < win_height)) {
				rect = all_circles.at(clicked);
				all_circles.put(clicked, rect.origin = Point(x, y) - relative_where);
				all_circles_center[clicked] = Point(x, y) - relative_where;
				simmetry[clicked] = all_circles_center[clicked];
				x = x - relative_where.x;
				y = y - relative_where.y;
				if (pen_menu.item == "pen: blip", {
					all_circles_sound[clicked].set(
						\freq, x + 40,
						\num_harm, (win_height - y) / 30
					);
				});
				if (pen_menu.item == "pen: saw", {
					all_circles_sound[clicked].set(
						\freq, x + 40,
						\fil_freq, 100 * (win_height - y)/10
					);
				});
				if (pen_menu.item == "pen: triangular", {
					all_circles_sound[clicked].set(
						\freq, x + 40,
						\fil_freq, 100 * (win_height - y)/10
					);
				});
				if (pen_menu.item == "pen: sinusoidal", {
					all_circles_sound[clicked].set(
						\freq, x + 40
					);
				});
				win.refresh;
			}
		};
	};

	win.onClose = {
		routines = routines.do({
			arg elem, i;
			elem.stop;
		});
		s.freeAll;
		Window.closeAll;
	};
	win.front;
});
)
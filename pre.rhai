let license = variable::get("license").to_upper();
while switch license {
	"GLWTPL" => {
		file::delete("LICENSE-MIT");
		file::delete("LICENSE-GPL3");
		file::rename("LICENSE-GLWTPL", "LICENSE");
		false
	}
	"MIT" => {
		file::delete("LICENSE-GLWTPL");
		file::delete("LICENSE-GPL3");
		file::rename("LICENSE-MIT", "LICENSE");
		false
	}
	"GPL3" => {
		file::delete("LICENSE-GLWTPL");
		file::delete("LICENSE-MIT");
		file::rename("LICENSE-GPL3", "LICENSE");
		false
	}
	_ => true,
} {
	license = variable::prompt("License?", "MIT", ["MIT", "GPL3", "GLWTPL"]);
}
variable::set("license", license)

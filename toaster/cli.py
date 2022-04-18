import click
from packages import install_package, remove_package
from utils import errecho, echo, secho
from bakery import refresh_bakeries
import sysupdates
from exceptions import *


@click.group()
def cli():
    pass


def refresh_db():
    """Refresh database"""
    secho(
        ':: Refreshing repositories...', fg='bright_magenta')
    refresh_bakeries()
    secho(
        'Repositories updated :)', fg='bright_green')


@click.command(help='Install packages')
@click.argument('packages', nargs=-1, required=True, type=str)
def install(packages):
    for package in packages:
        secho(
            f':: Installing {package}...', fg='bright_magenta')

        try:
            install_package(package)
        except NotFound:
            errecho(f'{package} could not be found.')
        except AlreadyInstalled:
            errecho(
                f'{package} is already installed. Do `toaster reinstall {package}` to reinstall.')
        except NotImplementedError:
            errecho(
                f'{package} was found but is not available because it is a binary or app which is not supported yet.')
        else:
            secho(
                f'{package} installed!', fg='bright_green')


@click.command(help='Remove packages')
@click.argument('packages', nargs=-1, required=True, type=str)
def remove(packages):
    for package in packages:
        secho(
            f':: Remoivng {package}...', fg='bright_magenta')
        try:
            remove_package(package)
        except NotFound:
            success = False
            errecho(f'{package} is not installed.')


@click.command(help='Update packages')
@click.argument('packages', nargs=-1, type=str)
@click.option('--refresh', help='Refresh Packages', default=True, type=bool)
def update(packages, refresh):
    if not packages:
        packages = ['all']

    if refresh:
        refresh_db()

    if 'all' in packages:
        secho(
            ':: Updating packages...', fg='bright_magenta')

        secho(
            ':: Checking for macOS updates...', fg='bright_magenta')

        c = sysupdates.check_updates()
        if c[0] != 0:
            errecho(
                'An error has occured while checking for updates.')
            exit(1)

        if c[1]:
            secho(':: System updates available, starting updates!',
                  fg='bright_magenta')

            r = sysupdates.all()

            if r != 0:
                errecho(
                    'An error has occured while updating your system.')
                exit(1)
        else:
            secho('All up to date! :)', fg='bright_green')
    else:
        pass


if __name__ == '__main__':
    cli.add_command(update)
    cli.add_command(install)
    cli.add_command(remove)
    cli()
